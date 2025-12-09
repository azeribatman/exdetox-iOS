import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    var onComplete: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var selections: [String: String] = [:]
    @State private var showCompletion = false
    @State private var celebratePulse = false
    
    private let creamBg = Color(hex: "F5F0E8")
    private let cardBg = Color(hex: "FFFDF9")
    
    var storyContent: [String] {
        if !article.content.isEmpty {
            return article.content
        }
        return [
            "This is the beginning of your journey. Take a deep breath and let the words guide you.",
            "Understanding the process is key to healing. It's not about forgetting, it's about growing.",
            "Every step forward, no matter how small, is a victory. Celebrate your progress.",
            "You are stronger than you know. Keep pushing forward and never look back."
        ]
    }
    
    var allQuestionsAnswered: Bool {
        article.quiz.isEmpty || article.quiz.allSatisfy { selections[$0.id] != nil }
    }
    
    var body: some View {
        ZStack {
            creamBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        categoryAndTime
                        titleSection
                        tldrCard
                        
                        if let quote = article.quote {
                            quoteCard(quote)
                        }
                        
                        actionCard
                        contentCard
                        
                        if !article.quiz.isEmpty {
                            quizSection
                        }
                        
                        finishButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
            
            if showCompletion {
                completionOverlay
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.primary.opacity(0.5))
                    .frame(width: 32, height: 32)
                    .background(cardBg)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("Reading")
                .font(.system(size: 16, weight: .bold, design: .rounded))
            
            Spacer()
            
            Color.clear.frame(width: 32, height: 32)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // MARK: - Category & Time
    
    private var categoryAndTime: some View {
        HStack(spacing: 10) {
            Text(article.category)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(article.imageColor.opacity(0.12))
                .foregroundStyle(article.imageColor)
                .clipShape(Capsule())
            
            Text(article.readTime)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
            
            Spacer()
        }
    }
    
    // MARK: - Title
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(article.title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text(article.subtitle)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - TL;DR Card
    
    private var tldrCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TL;DR")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            Text(article.tldr)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Quote Card
    
    private func quoteCard(_ quote: LessonQuote) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(quote.persona)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(article.imageColor)
            Text("\(quote.text)")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
                .italic()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(article.imageColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Action Card
    
    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                Text("Try this now")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            Text(article.action)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(.white)
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(article.imageColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Content Card
    
    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(storyContent, id: \.self) { paragraph in
                Text(paragraph)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineSpacing(5)
            }
        }
        .padding(14)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Quiz Section
    
    private var quizSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quick Check")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            ForEach(article.quiz) { question in
                quizQuestionCard(question)
            }
        }
    }
    
    private func quizQuestionCard(_ question: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.question)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
            
            VStack(spacing: 8) {
                ForEach(question.options) { option in
                    quizOptionButton(question: question, option: option)
                }
            }
            
            if let choice = selections[question.id] {
                let isCorrect = choice == question.correctOptionId
                HStack(spacing: 6) {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "info.circle.fill")
                        .font(.system(size: 12))
                    Text(question.explanation)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                }
                .foregroundStyle(isCorrect ? .green : .orange)
                .padding(.top, 4)
            }
        }
        .padding(14)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func quizOptionButton(question: QuizQuestion, option: QuizOption) -> some View {
        let selected = selections[question.id]
        let isSelected = selected == option.id
        let isCorrect = question.correctOptionId == option.id
        let hasAnswered = selected != nil
        
        return Button {
            if !hasAnswered {
                withAnimation(.spring(response: 0.3)) {
                    selections[question.id] = option.id
                }
                Haptics.feedback(style: .light)
            }
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.clear : Color.primary.opacity(0.2), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(isCorrect ? Color.green : Color.red)
                            .frame(width: 22, height: 22)
                        
                        Image(systemName: isCorrect ? "checkmark" : "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                
                Text(option.text)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? (isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    : creamBg
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected
                            ? (isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                            : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(hasAnswered)
    }
    
    // MARK: - Finish Button
    
    private var finishButton: some View {
        Button(action: { finishAndCelebrate() }) {
            HStack {
                Text(allQuestionsAnswered ? "Finish & Celebrate" : "Answer the quiz first")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(allQuestionsAnswered ? Color.black : Color.black.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!allQuestionsAnswered)
    }
    
    // MARK: - Completion Overlay
    
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("🎉")
                    .font(.system(size: 64))
                    .scaleEffect(celebratePulse ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: celebratePulse)
                
                Text("You did it!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("One more tool in your toolkit.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                
                Button {
                    showCompletion = false
                    dismiss()
                } label: {
                    Text("Keep Going")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.top, 8)
            }
            .padding(32)
        }
        .onAppear { celebratePulse = true }
        .onDisappear { celebratePulse = false }
        .transition(.opacity)
    }
    
    func finishAndCelebrate() {
        Haptics.notification(type: .success)
        withAnimation(.spring()) {
            showCompletion = true
        }
        onComplete()
    }
}
