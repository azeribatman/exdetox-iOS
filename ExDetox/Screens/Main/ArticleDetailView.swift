import SwiftUI
struct ArticleDetailView: View {
    let article: Article
    var onComplete: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var selections: [String: String] = [:]
    @State private var showCompletion = false
    @State private var celebratePulse = false
    
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
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        
                        Spacer()
                    }
                    
                    Text("Reading")
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 12) {
                            Text(article.category.uppercased())
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(article.imageColor.opacity(0.12))
                                .foregroundStyle(article.imageColor)
                                .clipShape(Capsule())
                            
                            Text(article.readTime)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(article.title)
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .foregroundStyle(.primary)
                            
                            Text(article.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TL;DR")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            Text(article.tldr)
                                .font(.body.weight(.medium))
                                .foregroundStyle(.primary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                        }
                        
                        if let quote = article.quote {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(quote.persona)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(article.imageColor)
                                Text("“\(quote.text)”")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(article.imageColor.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Try this now")
                                    .font(.subheadline.weight(.bold))
                                Spacer()
                            }
                            Text(article.action)
                                .font(.body.weight(.semibold))
                                .multilineTextAlignment(.leading)
                        }
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(article.imageColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: article.imageColor.opacity(0.25), radius: 8, x: 0, y: 4)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(storyContent, id: \.self) { paragraph in
                                Text(paragraph)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .lineSpacing(6)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 6)
                        
                        if !article.quiz.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Quick check: What would you do?")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(.primary)
                                
                                ForEach(article.quiz) { question in
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(question.question)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                        
                                        VStack(alignment: .leading, spacing: 10) {
                                            ForEach(question.options) { option in
                                                let selected = selections[question.id]
                                                let isSelected = selected == option.id
                                                let isCorrect = question.correctOptionId == option.id
                                                Button {
                                                    selections[question.id] = option.id
                                                } label: {
                                                    HStack(alignment: .top, spacing: 12) {
                                                        Text(option.text)
                                                            .font(.body)
                                                            .multilineTextAlignment(.leading)
                                                            .foregroundStyle(isSelected ? .white : .primary)
                                                        Spacer()
                                                        if isSelected {
                                                            Image(systemName: isCorrect ? "checkmark.seal.fill" : "xmark.seal.fill")
                                                                .foregroundStyle(.white)
                                                        }
                                                    }
                                                    .padding()
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .background(isSelected ? (isCorrect ? Color.green : Color.red) : Color.white)
                                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                                    .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        
                                        if let choice = selections[question.id] {
                                            let isCorrect = choice == question.correctOptionId
                                            Text(question.explanation)
                                                .font(.caption)
                                                .foregroundStyle(isCorrect ? Color.green : Color.red)
                                                .padding(.top, 4)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                                }
                            }
                        }
                        
                        Button(action: {
                            finishAndCelebrate()
                        }) {
                            HStack {
                                Text(allQuestionsAnswered ? "Finish & celebrate" : "Answer the quick check")
                                    .font(.headline.weight(.bold))
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(allQuestionsAnswered ? Color.black : Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .opacity(allQuestionsAnswered ? 1 : 0.6)
                        }
                        .disabled(!allQuestionsAnswered)
                        .padding(.bottom, 32)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            
            if showCompletion {
                ZStack {
                    LinearGradient(
                        colors: [
                            article.imageColor.opacity(0.25),
                            Color.black.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    Circle()
                        .fill(article.imageColor.opacity(0.25))
                        .frame(width: 240, height: 240)
                        .blur(radius: 40)
                        .scaleEffect(celebratePulse ? 1.05 : 0.95)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: celebratePulse)
                    
                    VStack(spacing: 14) {
                        Image(systemName: "party.popper.fill")
                            .font(.system(size: 52, weight: .bold))
                            .foregroundStyle(.white)
                            .scaleEffect(celebratePulse ? 1.05 : 0.95)
                            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: celebratePulse)
                        
                        Text("You did it!")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                        
                        Text("Nice, that’s one more tool in your mental health toolkit.")
                            .font(.subheadline.weight(.medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.horizontal, 32)
                        
                        HStack(spacing: 12) {
                            Button {
                                showCompletion = false
                                dismiss()
                            } label: {
                                Text("Keep going")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(article.imageColor)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.top, 6)
                    }
                    .padding()
                }
                .onAppear {
                    celebratePulse = true
                }
                .onDisappear {
                    celebratePulse = false
                }
                .transition(.opacity)
            }
        }
    }
    
    func finishAndCelebrate() {
        withAnimation(.spring()) {
            showCompletion = true
        }
        onComplete()
    }
}

//#Preview {
//    ArticleDetailView(
//        article: Article(
//            title: "Test",
//            subtitle: "Subtitle",
//            category: "Test",
//            readTime: "5m",
//            imageColor: .blue
//        ),
//        onComplete: {}
//    )
//}


