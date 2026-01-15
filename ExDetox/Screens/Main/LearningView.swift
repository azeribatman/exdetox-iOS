import SwiftUI
import SwiftData

struct LearningView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var completedLessons: [LearningProgressRecord]
    
    @State private var selectedArticle: Article?
    @State private var learningSections: [LearningSection] = []
    @State private var selectedSectionId: String?
    @State private var selectedLessonId: String?
    @State private var showSettings = false
    
    private let creamBg = Color(hex: "F5F0E8")
    private let cardBg = Color(hex: "FFFDF9")
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    if let spotlight = nextLessonHighlight() {
                        forYouCard(section: spotlight.section, lesson: spotlight.lesson)
                            .padding(.horizontal, 16)
                    }
                    
                    ForEach(learningSections.indices, id: \.self) { index in
                        sectionCard(section: $learningSections[index])
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .background(creamBg.ignoresSafeArea())
        .sheet(item: $selectedArticle) { article in
            ArticleDetailView(article: article, onComplete: {
                markCurrentLessonCompleted()
            })
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            loadLearningSectionsIfNeeded()
            
            // Track learning opened
            let totalCompleted = learningSections.reduce(0) { $0 + $1.completedCount }
            let totalLessons = learningSections.reduce(0) { $0 + $1.totalCount }
            AnalyticsManager.shared.trackLearningOpen(completedCount: totalCompleted, totalCount: totalLessons)
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack(alignment: .center) {
            Text("Learning")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 40, height: 40)
                    .background(cardBg)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // MARK: - Section Card
    
    func sectionCard(section: Binding<LearningSection>) -> some View {
        let completed = section.wrappedValue.completedCount
        let total = section.wrappedValue.totalCount
        let accent = section.wrappedValue.accentColor
        let progress = total == 0 ? 0 : Double(completed) / Double(total)
        
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Text(emojiForSection(id: section.wrappedValue.id))
                    .font(.system(size: 24))
                    .frame(width: 44, height: 44)
                    .background(accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(section.wrappedValue.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text("\(completed)/\(total) complete")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 5)
                    Capsule()
                        .fill(accent)
                        .frame(width: geo.size.width * progress, height: 5)
                        .animation(.spring(response: 0.5), value: progress)
                }
            }
            .frame(height: 5)
            
            VStack(spacing: 8) {
                ForEach(section.wrappedValue.lessons.prefix(4)) { lesson in
                    Button {
                        openLesson(sectionId: section.wrappedValue.id, lessonId: lesson.id)
                        Haptics.feedback(style: .light)
                    } label: {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(lesson.isCompleted ? accent : Color.primary.opacity(0.08))
                                    .frame(width: 26, height: 26)
                                
                                if lesson.isCompleted {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(lesson.title)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.leading)
                                Text(lesson.subtitle)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            
                            Text("3-5m")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(creamBg)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
        .padding(16)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
    }
    
    func loadLearningSectionsIfNeeded() {
        guard learningSections.isEmpty else { 
            syncCompletionStatus()
            return 
        }
        
        guard let url = Bundle.main.url(forResource: "learnings", withExtension: "json") else {
            print("learnings.json not found in bundle")
            return
        }
        
        let completedLessonIds = Set(completedLessons.map { $0.lessonId })
        
        do {
            let data = try Data(contentsOf: url)
            let dto = try JSONDecoder().decode(LearningsDTO.self, from: data)
            
            learningSections = dto.sections.map { section in
                let accent = colorForSection(id: section.id)
                return LearningSection(
                    id: section.id,
                    title: section.header,
                    accentColor: accent,
                    lessons: section.lessons.map { lesson in
                        LearningLesson(
                            id: lesson.id,
                            title: lesson.title,
                            subtitle: lesson.subtitle ?? "",
                            tldr: lesson.tldr ?? "",
                            action: lesson.action ?? "",
                            quote: lesson.quote,
                            quiz: lesson.quiz ?? [],
                            content: lesson.content ?? [],
                            isCompleted: completedLessonIds.contains(lesson.id)
                        )
                    }
                )
            }
        } catch {
            print("Failed to load learnings.json: \(error)")
        }
    }
    
    private func syncCompletionStatus() {
        let completedLessonIds = Set(completedLessons.map { $0.lessonId })
        for sectionIndex in learningSections.indices {
            for lessonIndex in learningSections[sectionIndex].lessons.indices {
                let lessonId = learningSections[sectionIndex].lessons[lessonIndex].id
                learningSections[sectionIndex].lessons[lessonIndex].isCompleted = completedLessonIds.contains(lessonId)
            }
        }
    }
    
    func openLesson(sectionId: String, lessonId: String) {
        guard let sectionIndex = learningSections.firstIndex(where: { $0.id == sectionId }),
              let lessonIndex = learningSections[sectionIndex].lessons.firstIndex(where: { $0.id == lessonId }) else {
            return
        }
        
        let section = learningSections[sectionIndex]
        let lesson = section.lessons[lessonIndex]
        let article = Article(
            title: lesson.title,
            subtitle: lesson.subtitle,
            category: section.title,
            readTime: "3–5 min",
            imageColor: section.accentColor,
            tldr: lesson.tldr,
            action: lesson.action,
            quote: lesson.quote,
            quiz: lesson.quiz,
            content: lesson.content
        )
        
        selectedSectionId = sectionId
        selectedLessonId = lessonId
        selectedArticle = article
    }
    
    func markCurrentLessonCompleted() {
        guard let sectionId = selectedSectionId,
              let lessonId = selectedLessonId,
              let sectionIndex = learningSections.firstIndex(where: { $0.id == sectionId }),
              let lessonIndex = learningSections[sectionIndex].lessons.firstIndex(where: { $0.id == lessonId }) else {
            return
        }
        
        learningSections[sectionIndex].lessons[lessonIndex].isCompleted = true
        
        let alreadyExists = completedLessons.contains { $0.lessonId == lessonId }
        if !alreadyExists {
            let progressRecord = LearningProgressRecord(lessonId: lessonId, sectionId: sectionId)
            modelContext.insert(progressRecord)
            try? modelContext.save()
        }
    }
    
    func colorForSection(id: String) -> Color {
        switch id {
        case "detox-your-ex":
            return .orange
        case "main-character-energy":
            return .purple
        case "red-flag-radar":
            return .red
        case "soft-life-reset":
            return .mint
        default:
            return .indigo
        }
    }
    
    func emojiForSection(id: String) -> String {
        switch id {
        case "detox-your-ex":
            return "🧼"
        case "main-character-energy":
            return "🌟"
        case "red-flag-radar":
            return "🚩"
        case "soft-life-reset":
            return "🌸"
        default:
            return "📚"
        }
    }
    
    func nextLessonHighlight() -> (section: LearningSection, lesson: LearningLesson)? {
        if let pending = learningSections.first(where: { $0.lessons.contains(where: { !$0.isCompleted }) }) {
            if let lesson = pending.lessons.first(where: { !$0.isCompleted }) {
                return (pending, lesson)
            }
        }
        if let firstSection = learningSections.first, let firstLesson = firstSection.lessons.first {
            return (firstSection, firstLesson)
        }
        return nil
    }
    
    func forYouCard(section: LearningSection, lesson: LearningLesson) -> some View {
        let accent = section.accentColor
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("Up Next")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                Text(emojiForSection(id: section.id))
                    .font(.system(size: 22))
            }
            
            Text(lesson.title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
            
            Text(lesson.tldr.isEmpty ? lesson.subtitle : lesson.tldr)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(2)
                .lineSpacing(2)
            
            Button {
                openLesson(sectionId: section.id, lessonId: lesson.id)
                Haptics.feedback(style: .medium)
            } label: {
                HStack {
                    Text("Start Learning")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(accent)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Models

struct Article: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: String
    let readTime: String
    let imageColor: Color
    let tldr: String
    let action: String
    let quote: LessonQuote?
    let quiz: [QuizQuestion]
    var content: [String] = []
}

struct LearningSection: Identifiable {
    let id: String
    let title: String
    let accentColor: Color
    var lessons: [LearningLesson]
    
    var completedCount: Int {
        lessons.filter { $0.isCompleted }.count
    }
    
    var totalCount: Int {
        lessons.count
    }
}

struct LearningLesson: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let tldr: String
    let action: String
    let quote: LessonQuote?
    let quiz: [QuizQuestion]
    let content: [String]
    var isCompleted: Bool
}

struct LearningsDTO: Decodable {
    let sections: [LearningSectionDTO]
}

struct LearningSectionDTO: Decodable {
    let id: String
    let header: String
    let lessons: [LearningLessonDTO]
}

struct LearningLessonDTO: Decodable {
    let id: String
    let title: String
    let subtitle: String?
    let tldr: String?
    let action: String?
    let quote: LessonQuote?
    let quiz: [QuizQuestion]?
    let content: [String]?
}

struct LessonQuote: Decodable {
    let persona: String
    let text: String
}

struct QuizQuestion: Decodable, Identifiable {
    var id: String { question }
    let question: String
    let options: [QuizOption]
    let correctOptionId: String
    let explanation: String
}

struct QuizOption: Decodable, Identifiable {
    let id: String
    let text: String
}

#Preview {
    LearningView()
        .modelContainer(for: [LearningProgressRecord.self], inMemory: true)
}
