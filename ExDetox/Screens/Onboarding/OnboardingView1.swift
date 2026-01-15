import SwiftUI

struct OnboardingView1: View {
    @Environment(Router.self) private var router
    
    // MARK: - Animation States
    @State private var phase: AnimationPhase = .darkness
    
    // Message States
    @State private var showMsg1 = false
    @State private var showMsg2 = false
    @State private var showMsg3 = false
    @State private var showMsg4 = false
    @State private var showMsg5 = false
    
    // Light Phase States
    @State private var revealRadius: CGFloat = 0
    @State private var showLogo = false
    @State private var showContent = false
    
    // Floating Animation
    @State private var floatOffset: CGFloat = 0
    
    enum AnimationPhase {
        case darkness
        case transition
        case light
    }
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
//            let maxRadius = max(geometry.size.width, geometry.size.height) * 1.5
            
            ZStack {
                // MARK: - Layer 1: Light Phase (Bottom)
                Color(hex: "F9F9F9").ignoresSafeArea()
                
                if phase == .transition || phase == .light {
                    lightPhaseContent(geometry)
                }
                
                // MARK: - Layer 2: Dark Phase (Top Overlay)
                if phase == .darkness || phase == .transition {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        
                        // Dark Content Container
                        ZStack {
                            // Central "User"
                            Text("😔")
                                .font(.system(size: 80))
                                .scaleEffect(showMsg5 ? 0.9 : 1.0)
                                .blur(radius: showMsg5 ? 3 : 0)
                                .animation(.easeInOut(duration: 0.4), value: showMsg5)
                                .position(center)
                                .offset(y: floatOffset)
                            
                            // Messages
                            Group {
                                if showMsg1 {
                                    EmojiMessage(emoji: "👱🏻‍♂️", text: "We need to talk...", isLeft: true)
                                        .position(x: center.x - 90, y: center.y - 180)
                                        .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity), removal: .opacity))
                                }
                                
                                if showMsg2 {
                                    EmojiMessage(emoji: "👩🏼", text: "It's not you, it's me", isLeft: false)
                                        .position(x: center.x + 80, y: center.y - 90)
                                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                                }
                                
                                if showMsg3 {
                                    EmojiMessage(emoji: "🧔🏻‍♂️", text: "I need space", isLeft: true)
                                        .position(x: center.x - 70, y: center.y + 100)
                                        .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity), removal: .opacity))
                                }
                                
                                if showMsg4 {
                                    EmojiMessage(emoji: "👱‍♀️", text: "Please stop calling", isLeft: false)
                                        .position(x: center.x + 70, y: center.y + 210)
                                        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                                }
                                
                                if showMsg5 {
                                    VStack(spacing: 8) {
                                        Text("💔")
                                            .font(.system(size: 70))
                                            .symbolEffect(.bounce, value: showMsg5)
                                        Text("IT'S OVER")
                                            .font(.system(size: 40, weight: .black, design: .rounded))
                                            .foregroundColor(.red)
                                            .shadow(color: .red.opacity(0.8), radius: 20)
                                    }
                                    .position(x: center.x, y: center.y)
                                    .transition(.scale(scale: 0.1).combined(with: .opacity))
                                    .zIndex(100)
                                }
                            }
                            .offset(y: floatOffset)
                        }
                    }
                    // The Magic Reveal: Clip the black layer with a hole
                    .mask(
                        HoleShape(radius: revealRadius)
                            .fill(style: FillStyle(eoFill: true))
                            .ignoresSafeArea()
                    )
                    // Ensure touches don't get blocked once revealed (though logic hides this view anyway)
                    .allowsHitTesting(phase == .darkness)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            runCinematicSequence()
            startFloating()
            
            // Track onboarding start
            AnalyticsManager.shared.trackOnboardingStep(step: 1, name: "welcome")
            FirebaseAnalyticsManager.shared.trackOnboardingStart()
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }
    
    // MARK: - Light Phase Content
    @ViewBuilder
    private func lightPhaseContent(_ geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Logo Area
            ZStack {
                // Background Glow
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color.pink.opacity(0.15))
                    .frame(width: 160, height: 160)
                    .blur(radius: 30)
                    .scaleEffect(showLogo ? 1 : 0.5)
                    .opacity(showLogo ? 1 : 0)
                
                // Logo Placeholder
                Image(.commonAppicon)
                    .build(size: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
                    .scaleEffect(showLogo ? 1 : 0.01)
                    .rotationEffect(.degrees(showLogo ? 0 : -10))
                    .opacity(showLogo ? 1 : 0)
                    .animation(.spring(response: 0.7, dampingFraction: 0.6), value: showLogo)
            }
            .padding(.bottom, 30)
            
            // Text Content
            VStack(spacing: 16) {
                Text("Ex Who?")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: showContent)
                
                Text("It’s time to focus on you. Block the noise, heal the heart, and level up.\nYour glow up starts now.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
                    .lineSpacing(6)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)
            }
            
            Spacer()
            Spacer()
            
            // CTA Button
            if showContent {
                Button(action: {
                    Haptics.feedback(style: .medium)
                    router.navigate(.onboarding2)
                }) {
                    Text("Start Healing")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Animations
    private func startFloating() {
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            floatOffset = 15
        }
    }
    
    private func runCinematicSequence() {
        // Sequence Timing (seconds)
        let t1 = 0.8
        let t2 = 1.8
        let t3 = 2.8
        let t4 = 3.8
        let tBreakup = 4.8
        let tReveal = 6.5
        
        // Msg 1
        DispatchQueue.main.asyncAfter(deadline: .now() + t1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { showMsg1 = true }
            Haptics.feedback(style: .medium)
        }
        
        // Msg 2
        DispatchQueue.main.asyncAfter(deadline: .now() + t2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { showMsg2 = true }
            Haptics.feedback(style: .medium)
        }
        
        // Msg 3
        DispatchQueue.main.asyncAfter(deadline: .now() + t3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { showMsg3 = true }
            Haptics.feedback(style: .heavy)
        }
        
        // Msg 4
        DispatchQueue.main.asyncAfter(deadline: .now() + t4) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { showMsg4 = true }
            Haptics.feedback(style: .medium)
        }
        
        // THE BREAKUP
        DispatchQueue.main.asyncAfter(deadline: .now() + tBreakup) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) { showMsg5 = true }
            Haptics.notification(type: .error)
        }
        
        // REVEAL
        DispatchQueue.main.asyncAfter(deadline: .now() + tReveal) {
            Haptics.notification(type: .success)
            phase = .transition
            
            // Calculate max radius for screen
            let screenHeight = UIScreen.main.bounds.height
            let screenWidth = UIScreen.main.bounds.width
            let targetRadius = max(screenHeight, screenWidth) * 1.5
            
            withAnimation(.easeInOut(duration: 1.5)) {
                revealRadius = targetRadius
            }
        }
        
        // Light Phase Finalize
        DispatchQueue.main.asyncAfter(deadline: .now() + tReveal + 1.0) {
            phase = .light
            showLogo = true
        }
        
        // Content
        DispatchQueue.main.asyncAfter(deadline: .now() + tReveal + 1.5) {
            withAnimation {
                showContent = true
            }
        }
    }
}

// MARK: - Helpers

// Shape that creates a hole in a rectangle
struct HoleShape: Shape {
    var radius: CGFloat
    
    var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // The outer rectangle (the screen)
        path.addRect(rect)
        
        // The hole (circle)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.addEllipse(in: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ))
        
        return path
    }
}

struct EmojiMessage: View {
    let emoji: String
    let text: String
    let isLeft: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isLeft {
                Text(emoji)
                    .font(.system(size: 40))
                    .offset(y: 5)
            }
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(hex: "2C2C2E"))
                .clipShape(OnboardingChatBubbleShape(isLeft: isLeft))
                .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
            
            if !isLeft {
                Text(emoji)
                    .font(.system(size: 40))
                    .offset(y: 5)
            }
        }
    }
}

private struct OnboardingChatBubbleShape: Shape {
    let isLeft: Bool
    
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 18
        
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [
                .topLeft,
                .topRight,
                isLeft ? .bottomRight : .bottomLeft,
                isLeft ? .bottomLeft : .bottomRight
            ],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        
        return Path(path.cgPath)
    }
}

#Preview {
    OnboardingView1()
        .environment(Router())
}
