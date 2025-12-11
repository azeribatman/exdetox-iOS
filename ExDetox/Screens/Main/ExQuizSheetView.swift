import SwiftUI

struct ExQuizSheetView: View {
    let message: ExQuizMessage
    let exName: String
    let onDismiss: () -> Void
    
    @State private var phase = 0
    @State private var selectedAnswer: String?
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var confettiCounter = 0
    @State private var showContent = false
    @State private var messageScale: CGFloat = 0.9
    @State private var messageOpacity: Double = 0
    @State private var answersVisible: [Bool] = [false, false, false]
    @State private var resultScale: CGFloat = 0.8
    @State private var resultOpacity: Double = 0
    @State private var decodedOpacity: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    private var shuffledAnswers: [String] {
        (message.wrongAnswers + [message.rightAnswer]).shuffled()
    }
    
    @State private var answers: [String] = []
    
    var body: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                    
                    Spacer().frame(height: 32)
                    
                    if !showResult {
                        messageCard
                            .scaleEffect(messageScale)
                            .opacity(messageOpacity)
                        
                        Spacer().frame(height: 32)
                        
                        questionSection
                        
                        Spacer().frame(height: 24)
                        
                        answersSection
                    } else {
                        resultSection
                    }
                    
                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            
            VStack {
                Spacer()
                
                if showResult {
                    Button(action: {
                        Haptics.feedback(style: .medium)
                        onDismiss()
                    }) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .confettiCannon(counter: $confettiCounter, num: 50, confettis: [.text("🎉"), .text("✨"), .text("💪"), .text("🔥")], confettiSize: 25, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200)
        .onAppear {
            answers = shuffledAnswers
            startAnimation()
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("🚨 INCOMING MESSAGE")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(Color(hex: "FF6B6B"))
                
                Text("What would you say?")
                    .font(.system(size: 28, weight: .black, design: .rounded))
            }
            
            Spacer()
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
    }
    
    private var messageCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "FF6B6B").opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Text("💔")
                        .font(.system(size: 22))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(exName.isEmpty ? "Ex" : exName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: "FF6B6B"))
                            .frame(width: 6, height: 6)
                        Text("Just now")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            
            Text(message.text)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .lineSpacing(4)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color(hex: "FF6B6B").opacity(0.15), radius: 20, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(hex: "FF6B6B").opacity(0.2), lineWidth: 1)
        )
    }
    
    private var questionSection: some View {
        HStack {
            Text("Your response:")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            
            Spacer()
        }
        .opacity(showContent ? 1 : 0)
    }
    
    private var answersSection: some View {
        VStack(spacing: 12) {
            ForEach(Array(answers.enumerated()), id: \.offset) { index, answer in
                if answersVisible.indices.contains(index) && answersVisible[index] {
                    answerButton(answer: answer, index: index)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
        }
    }
    
    private func answerButton(answer: String, index: Int) -> some View {
        Button(action: {
            selectAnswer(answer)
        }) {
            HStack {
                Text(answer)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if selectedAnswer == answer {
                    if answer == message.rightAnswer {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color(hex: "34C759"))
                    } else {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color(hex: "FF6B6B"))
                    }
                } else {
                    Circle()
                        .stroke(Color.black.opacity(0.1), lineWidth: 2)
                        .frame(width: 22, height: 22)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(selectedAnswer == answer
                          ? (answer == message.rightAnswer ? Color(hex: "34C759").opacity(0.1) : Color(hex: "FF6B6B").opacity(0.1))
                          : Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(selectedAnswer == answer
                            ? (answer == message.rightAnswer ? Color(hex: "34C759") : Color(hex: "FF6B6B"))
                            : Color.clear, lineWidth: 2)
            )
        }
        .disabled(selectedAnswer != nil)
    }
    
    private var resultSection: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(isCorrect ? Color(hex: "34C759").opacity(0.1) : Color(hex: "FF9500").opacity(0.1))
                    .frame(width: 140, height: 140)
                    .scaleEffect(pulseScale)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 120, height: 120)
                    .shadow(color: (isCorrect ? Color(hex: "34C759") : Color(hex: "FF9500")).opacity(0.2), radius: 20, y: 8)
                
                Text(isCorrect ? "💪" : "🧠")
                    .font(.system(size: 56))
            }
            .scaleEffect(resultScale)
            .opacity(resultOpacity)
            
            VStack(spacing: 12) {
                Text(isCorrect ? "You stayed strong!" : "That's what they wanted...")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text(isCorrect
                     ? "You saw right through their manipulation. Main character energy! 🔥"
                     : "But now you know better. Every time you recognize the pattern, you get stronger.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .opacity(resultOpacity)
            
            VStack(spacing: 12) {
                Text("DECODED MEANING")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color(hex: "6366F1"))
                    
                    Text(message.decodedMeaning)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "6366F1"))
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(hex: "6366F1").opacity(0.1))
                )
            }
            .opacity(decodedOpacity)
        }
    }
    
    private func startAnimation() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showContent = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                messageScale = 1.0
                messageOpacity = 1.0
            }
            Haptics.feedback(style: .medium)
        }
        
        for i in 0..<answers.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 + Double(i) * 0.15) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    if answersVisible.indices.contains(i) {
                        answersVisible[i] = true
                    }
                }
                Haptics.feedback(style: .light)
            }
        }
    }
    
    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        isCorrect = answer == message.rightAnswer
        Haptics.feedback(style: .medium)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showResult = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    resultScale = 1.0
                    resultOpacity = 1.0
                }
                
                confettiCounter += 1
                Haptics.notification(type: .success)
                
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulseScale = 1.1
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    decodedOpacity = 1.0
                }
            }
        }
    }
}

#Preview {
    ExQuizSheetView(
        message: ExQuizMessage(
            id: "test",
            text: "I miss you...",
            exGenders: ["male", "female", "other"],
            wrongAnswers: ["I miss you too 💔", "Can we meet up?"],
            rightAnswer: "Nice try 🚩",
            decodedMeaning: "They're bored and lonely"
        ),
        exName: "Alex",
        onDismiss: {}
    )
}
