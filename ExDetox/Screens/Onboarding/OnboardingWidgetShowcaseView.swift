import SwiftUI

struct OnboardingWidgetShowcaseView: View {
    @Environment(Router.self) private var router
    var onContinue: (() -> Void)? = nil
    
    @State private var phase = 0
    @State private var showHomeWidget = false
    @State private var showLockWidget = false
    @State private var homeWidgetOffset: CGFloat = 100
    @State private var lockWidgetOffset: CGFloat = 100
    @State private var pulseHome = false
    @State private var pulseLock = false
    @State private var streakCount = 0
    @State private var showCTA = false
    @State private var floatAnimation = false
    @State private var showPhone = false
    @State private var phoneScale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Title
                if phase >= 1 {
                    VStack(spacing: 16) {
                        Text("WIDGETS")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .tracking(4)
                            .foregroundStyle(.secondary)
                        
                        Text("Your streak.\nEverywhere.")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }
                
                // iPhone mockup with widgets
                if phase >= 2 {
                    iPhoneWidgetMockup(
                        streakCount: streakCount,
                        showHomeWidget: showHomeWidget,
                        showLockWidget: showLockWidget,
                        homeWidgetOffset: homeWidgetOffset,
                        lockWidgetOffset: lockWidgetOffset
                    )
                    .scaleEffect(phoneScale)
                    .opacity(showPhone ? 1 : 0)
                    .transition(.scale.combined(with: .opacity))
                    .padding(.horizontal, 40)
                    .padding(.vertical, 10)
                } else {
                    Spacer()
                }
                
                // Features - minimal
                if phase >= 3 {
                    VStack(spacing: 12) {
                        featureRow(text: "Track your streak instantly")
                        featureRow(text: "Stay motivated every unlock")
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // CTA
                if showCTA {
                    Button(action: {
                        Haptics.feedback(style: .medium)
                        if let onContinue = onContinue {
                            onContinue()
                        } else {
                            router.navigate(.onboarding4)
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            startAnimation()
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func featureRow(text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.green)
            
            Text(text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
            
            Spacer()
        }
    }
    
    private func startAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            phase = 1
        }
        Haptics.feedback(style: .medium)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                phase = 2
                showPhone = true
            }
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                phoneScale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                    showHomeWidget = true
                    homeWidgetOffset = 0
                }
                Haptics.feedback(style: .light)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        showLockWidget = true
                        lockWidgetOffset = 0
                    }
                    Haptics.feedback(style: .light)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    animateStreakCount()
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                phase = 3
            }
            Haptics.feedback(style: .light)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showCTA = true
            }
        }
    }
    
    private func animateStreakCount() {
        let target = 7
        let stepDuration = 0.8 / Double(target)
        
        for i in 1...target {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDuration) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                    streakCount = i
                }
                if i == target {
                    Haptics.notification(type: .success)
                }
            }
        }
    }
}

struct iPhoneWidgetMockup: View {
    let streakCount: Int
    let showHomeWidget: Bool
    let showLockWidget: Bool
    let homeWidgetOffset: CGFloat
    let lockWidgetOffset: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let cornerRadius = width * 0.14
            
            ZStack {
                // Frame
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.gray.opacity(0.3), lineWidth: width * 0.02)
                    )
                    .shadow(color: .black.opacity(0.2), radius: width * 0.08, y: width * 0.04)
                
                // Screen
                RoundedRectangle(cornerRadius: cornerRadius * 0.85, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1C1C1E"), Color(hex: "2C2C2E")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(width * 0.035)
                
                // Dynamic Island
                VStack {
                    Capsule()
                        .fill(Color.black)
                        .frame(width: width * 0.3, height: width * 0.09)
                        .padding(.top, width * 0.06)
                    Spacer()
                }
                
                // Content
                VStack(spacing: 0) {
                    Spacer().frame(height: height * 0.15)
                    
                    // Home Widget
                    ZStack {
                        RoundedRectangle(cornerRadius: width * 0.08, style: .continuous)
                            .fill(Color(hex: "1C1C1E"))
                            .overlay(
                                RoundedRectangle(cornerRadius: width * 0.08, style: .continuous)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        
                        VStack(spacing: 0) {
                            Text("ExDetox")
                                .font(.system(size: width * 0.035, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.4))
                            
                            Spacer()
                            
                            Text("\(streakCount)")
                                .font(.system(size: width * 0.15, weight: .regular, design: .serif))
                                .foregroundStyle(.white)
                                .contentTransition(.numericText(value: Double(streakCount)))
                            
                            Text("days")
                                .font(.system(size: width * 0.04, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.4))
                                .textCase(.uppercase)
                                .tracking(2)
                            
                            Spacer()
                            
                            Text("Be Proud")
                                .font(.system(size: width * 0.03, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.3))
                                .italic()
                        }
                        .padding(width * 0.05)
                    }
                    .frame(width: width * 0.5, height: width * 0.5)
                    .scaleEffect(showHomeWidget ? 1 : 0.5)
                    .opacity(showHomeWidget ? 1 : 0)
                    .offset(y: homeWidgetOffset)
                    
                    Spacer().frame(height: height * 0.05)
                    
                    // Lock Widget
                    ZStack {
                        RoundedRectangle(cornerRadius: width * 0.06, style: .continuous)
                            .fill(Color(hex: "2C2C2E"))
                            .overlay(
                                RoundedRectangle(cornerRadius: width * 0.06, style: .continuous)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        
                        HStack(spacing: 0) {
                            VStack(spacing: -1) {
                                Text("\(streakCount)")
                                    .font(.system(size: width * 0.08, weight: .regular, design: .serif))
                                    .foregroundStyle(.white)
                                    .contentTransition(.numericText(value: Double(streakCount)))
                                Text("days")
                                    .font(.system(size: width * 0.025, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.5))
                                    .textCase(.uppercase)
                                    .tracking(1)
                            }
                            .frame(width: width * 0.15)
                            
                            Rectangle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 1, height: width * 0.1)
                                .padding(.horizontal, width * 0.03)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("ExDetox")
                                    .font(.system(size: width * 0.035, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                                Text("Be Proud")
                                    .font(.system(size: width * 0.025, weight: .regular, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.5))
                                    .italic()
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, width * 0.04)
                    }
                    .frame(width: width * 0.75, height: width * 0.22)
                    .scaleEffect(showLockWidget ? 1 : 0.5)
                    .opacity(showLockWidget ? 1 : 0)
                    .offset(y: lockWidgetOffset)
                    
                    Spacer()
                }
            }
        }
        .aspectRatio(0.5, contentMode: .fit)
    }
}

#Preview {
    OnboardingWidgetShowcaseView()
        .environment(Router())
}
