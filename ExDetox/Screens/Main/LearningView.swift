import SwiftUI

struct LearningView: View {
    @State private var showSettings = false
    @State private var selectedArticle: Article?
    @State private var learningSections: [LearningSection] = []
    @State private var selectedSectionId: String?
    @State private var selectedLessonId: String?
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .background(Color(hex: "F9F9F9"))
            
            ScrollView {
                VStack(spacing: 16) {
                    if let spotlight = nextLessonHighlight() {
                        forYouCard(section: spotlight.section, lesson: spotlight.lesson)
                            .padding(.horizontal, 20)
                    }
                    
                    ForEach(learningSections.indices, id: \.self) { index in
                        sectionCard(section: $learningSections[index])
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
        }
        .background(Color(hex: "F9F9F9").ignoresSafeArea())
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(item: $selectedArticle) { article in
            ArticleDetailView(article: article, onComplete: {
                markCurrentLessonCompleted()
            })
        }
        .onAppear {
            loadLearningSectionsIfNeeded()
        }
    }
    
    // MARK: - Subviews
    
    var headerView: some View {
        HStack {
            Text("Learning")
                .font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.black)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
        }
        .frame(height: 62)
        .padding(.horizontal, 20)
    }
    
    func sectionCard(section: Binding<LearningSection>) -> some View {
        let completed = section.wrappedValue.completedCount
        let total = section.wrappedValue.totalCount
        let accent = section.wrappedValue.accentColor
        let progress = total == 0 ? 0 : Double(completed) / Double(total)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(emojiForSection(id: section.wrappedValue.id))
                    .font(.title3)
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.wrappedValue.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.primary)
                    Text("\(completed) of \(total) done")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.12))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(accent)
                        .frame(width: geo.size.width * progress, height: 8)
                        .animation(.easeInOut(duration: 0.25), value: progress)
                }
            }
            .frame(height: 8)
            
            VStack(spacing: 10) {
                ForEach(section.wrappedValue.lessons.prefix(4)) { lesson in
                    Button {
                        openLesson(sectionId: section.wrappedValue.id, lessonId: lesson.id)
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(lesson.isCompleted ? accent : Color.gray.opacity(0.2))
                                .frame(width: 10, height: 10)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(lesson.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(2)
                                Text(lesson.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Text("3–5 min")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 6)
        .padding(.horizontal, 20)
    }
    
    func loadLearningSectionsIfNeeded() {
        guard learningSections.isEmpty else { return }
        
        guard let url = Bundle.main.url(forResource: "learnings", withExtension: "json") else {
            print("learnings.json not found in bundle")
            return
        }
        
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
                            isCompleted: false
                        )
                    }
                )
            }
        } catch {
            print("Failed to load learnings.json: \(error)")
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
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Text("For you today")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
                Text(emojiForSection(id: section.id))
                    .font(.title3)
            }
            
            Text(lesson.title)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(2)
            
            Text(lesson.tldr.isEmpty ? lesson.subtitle : lesson.tldr)
                .font(.callout)
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            Button {
                openLesson(sectionId: section.id, lessonId: lesson.id)
            } label: {
                HStack {
                    Text("Start")
                        .font(.subheadline.weight(.bold))
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.subheadline.weight(.bold))
                }
                .foregroundStyle(accent)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.85),
                    accent.opacity(0.65)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: accent.opacity(0.25), radius: 12, x: 0, y: 6)
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
}
