import SwiftUI

struct StreakCelebrationView: View {
    let previousStreak: Int
    let currentStreak: Int
    let onDismiss: () -> Void
    
    @State private var displayedStreak: Int
    @State private var showContent = false
    @State private var emojiScale: CGFloat = 0
    @State private var numberScale: CGFloat = 0.5
    @State private var titleOpacity: Double = 0
    @State private var messageOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var confettiCounter = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0
    @State private var ring2Scale: CGFloat = 0.5
    @State private var ring2Opacity: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var floatOffset: CGFloat = 0
    @State private var cachedCelebrationData: (emoji: String, title: String, message: String, notification: String)?
    
    private let notificationManager = LocalNotificationManager.shared
    
    private var celebrationData: (emoji: String, title: String, message: String, notification: String) {
        cachedCelebrationData ?? notificationManager.getCelebration(forDay: currentStreak)
    }
    
    init(previousStreak: Int, currentStreak: Int, onDismiss: @escaping () -> Void) {
        self.previousStreak = previousStreak
        self.currentStreak = currentStreak
        self.onDismiss = onDismiss
        self._displayedStreak = State(initialValue: previousStreak)
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                streakSection
                
                Spacer().frame(height: 40)
                
                textSection
                
                Spacer()
                
                buttonSection
            }
            .padding(.horizontal, 24)
        }
        .confettiCannon(counter: $confettiCounter, num: 80, confettis: [.text("🔥"), .text("✨"), .text("💪"), .text("🎉"), .text(celebrationData.emoji)], confettiSize: 30, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 250)
        .onAppear {
            cachedCelebrationData = notificationManager.getCelebration(forDay: currentStreak)
            startAnimation()
            startFloating()
        }
    }
    
    private var streakSection: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 3)
                .frame(width: 220, height: 220)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)
            
            Circle()
                .stroke(Color.white.opacity(0.05), lineWidth: 2)
                .frame(width: 280, height: 280)
                .scaleEffect(ring2Scale)
                .opacity(ring2Opacity)
            
            VStack(spacing: 8) {
                Text(celebrationData.emoji)
                    .font(.system(size: 60))
                    .scaleEffect(emojiScale)
                    .offset(y: floatOffset)
                
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(displayedStreak)")
                        .font(.system(size: 100, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText(value: Double(displayedStreak)))
                        .scaleEffect(numberScale)
                    
                    Text("days")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .offset(y: -8)
                }
                .scaleEffect(pulseScale)
            }
        }
    }
    
    private var formattedTitle: String {
        celebrationData.title.replacingOccurrences(of: "{streak}", with: "\(displayedStreak)")
    }
    
    private var textSection: some View {
        VStack(spacing: 16) {
            Text(formattedTitle)
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .opacity(titleOpacity)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3), value: displayedStreak)
            
            Text(celebrationData.message.replacingOccurrences(of: "{streak}", with: "\(currentStreak)"))
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 20)
                .opacity(messageOpacity)
        }
    }
    
    private var buttonSection: some View {
        Button(action: {
            Haptics.feedback(style: .medium)
            onDismiss()
        }) {
            Text("Keep Going 🔥")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .white.opacity(0.3), radius: 20, y: 0)
        }
        .padding(.bottom, 50)
        .opacity(buttonOpacity)
    }
    
    private func startFloating() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            floatOffset = 10
        }
    }
    
    private func startAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            emojiScale = 1.0
        }
        Haptics.feedback(style: .heavy)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                numberScale = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.6)) {
                ringScale = 1.0
                ringOpacity = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.6)) {
                ring2Scale = 1.0
                ring2Opacity = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            animateStreakCount()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                titleOpacity = 1.0
            }
            Haptics.notification(type: .success)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                messageOpacity = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                buttonOpacity = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            confettiCounter += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
    }
    
    private func animateStreakCount() {
        guard previousStreak < currentStreak else { return }
        
        let difference = currentStreak - previousStreak
        let duration: TimeInterval = min(Double(difference) * 0.15, 1.5)
        let steps = difference
        let stepDuration = duration / Double(steps)
        
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDuration) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                    displayedStreak = previousStreak + i
                }
                
                if i == steps {
                    Haptics.notification(type: .success)
                } else {
                    Haptics.feedback(style: .light)
                }
            }
        }
    }
}

#Preview {
    StreakCelebrationView(
        previousStreak: 6,
        currentStreak: 7,
        onDismiss: {}
    )
}

#Preview("Big Jump") {
    StreakCelebrationView(
        previousStreak: 0,
        currentStreak: 30,
        onDismiss: {}
    )
}
