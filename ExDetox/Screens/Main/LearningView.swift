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
                VStack(spacing: 24) {
                    ForEach(learningSections.indices, id: \.self) { index in
                        sectionCard(section: $learningSections[index])
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 40)
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
                .font(.title2)
                .fontWeight(.bold)
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
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text(emojiForSection(id: section.wrappedValue.id))
                    .font(.title3)
                Text(section.wrappedValue.title.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    ForEach(0..<total, id: \.self) { index in
                        VStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(index < completed ? accent : Color.gray.opacity(0.2))
                                .shadow(color: index < completed ? accent.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                            
                            Text("#\(index + 1)")
                                .font(.caption2)
                                .fontWeight(index < completed ? .bold : .medium)
                                .foregroundStyle(index < completed ? accent : .secondary.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(completed) of \(total) lessons completed")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        Text(completed < total ? "Tap a lesson below to keep your streak going." : "Section complete. This is healed behavior.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(total == 0 ? 0 : Double(completed) / Double(total)))
                        .stroke(accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(-90))
                        .background(
                            Circle()
                                .stroke(Color.gray.opacity(0.1), lineWidth: 4)
                        )
                        .overlay(
                            Text("\(completed)/\(total)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.primary)
                        )
                        .animation(.easeInOut, value: completed)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(section.wrappedValue.lessons.indices, id: \.self) { lessonIndex in
                            let lesson = section.wrappedValue.lessons[lessonIndex]
                            
                            Button {
                                openLesson(sectionId: section.wrappedValue.id, lessonId: lesson.id)
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 10) {
                                        Circle()
                                            .fill(accent.opacity(0.15))
                                            .frame(width: 38, height: 38)
                                            .overlay(
                                                Image(systemName: lesson.isCompleted ? "checkmark.seal.fill" : "sparkles")
                                                    .font(.system(size: 17, weight: .semibold))
                                                    .foregroundStyle(accent)
                                            )
                                        
                                        Spacer()
                                        
                                        Text(lesson.isCompleted ? "Done" : "New")
                                            .font(.caption2.weight(.bold))
                                            .foregroundStyle(lesson.isCompleted ? accent : .secondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background((lesson.isCompleted ? accent : Color.gray.opacity(0.12)).opacity(0.12))
                                            .clipShape(Capsule())
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(lesson.title)
                                            .font(.subheadline.weight(.bold))
                                            .foregroundStyle(.primary)
                                            .lineLimit(2)
                                        
                                        Text(lesson.subtitle)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }
                                    
                                    Spacer(minLength: 0)
                                    
                                    HStack {
                                        Text("3–5 min")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption2.weight(.bold))
                                            .foregroundStyle(.secondary.opacity(0.6))
                                    }
                                }
                                .padding(12)
                                .frame(width: 220, alignment: .leading)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
        }
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
}

// MARK: - Models

struct Article: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: String
    let readTime: String
    let imageColor: Color
    var content: [String] = [] // Added content property
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
    let content: [String]?
}

#Preview {
    LearningView()
}
