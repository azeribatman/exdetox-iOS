import SwiftUI

struct OnboardingView3: View {
    @Environment(Router.self) private var router
    
    enum CinematicPhase: CaseIterable {
        case scanning
        case threats
        case aiDecoder
        case panicShield
        case growthTracker
        case ready
    }
    
    @State private var phase: CinematicPhase = .scanning
    
    @State private var scanPercent: Int = 0
    @State private var scanText = "Initializing..."
    @State private var scanTexts = [
        "Reading your story...",
        "Mapping pain points...",
        "Analyzing patterns...",
        "Building your armor...",
        "Preparing your journey..."
    ]
    @State private var currentScanIndex = 0
    @State private var pulseRing = false
    
    @State private var threatCount: Int = 0
    @State private var threatsRevealed: [Bool] = [false, false, false]
    let threats = [
        ("Late Night Texts", "message.fill", Color(hex: "FF6B6B")),
        ("Social Stalking", "eye.fill", Color(hex: "F59E0B")),
        ("Memory Triggers", "brain.head.profile", Color(hex: "8B5CF6"))
    ]
    
    @State private var showMessage = false
    @State private var messageScanned = false
    @State private var messageDecoded = false
    @State private var scanLineOffset: CGFloat = -60
    
    @State private var shieldScale: CGFloat = 0
    @State private var shieldPulse = false
    @State private var blockedCount: Int = 0
    @State private var chaosOpacity: Double = 1
    
    @State private var pathProgress: CGFloat = 0
    @State private var milestones: [Bool] = [false, false, false, false]
    @State private var sparklePhase = false
    
    @State private var readyScale: CGFloat = 0.8
    @State private var readyOpacity: Double = 0
    @State private var ctaVisible = false
    
    var body: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                StoryProgressIndicator(currentPhase: phaseIndex(phase), totalPhases: CinematicPhase.allCases.count)
                    .padding(.top, 60)
                    .padding(.horizontal, 24)
                
                Spacer()
                
                ZStack {
                    switch phase {
                    case .scanning:
                        scanningView
                            .transition(.asymmetric(
                                insertion: .opacity,
                                removal: .scale(scale: 1.1).combined(with: .opacity)
                            ))
                    case .threats:
                        threatsView
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.95).combined(with: .opacity),
                                removal: .opacity
                            ))
                    case .aiDecoder:
                        aiDecoderView
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .opacity
                            ))
                    case .panicShield:
                        panicShieldView
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.9).combined(with: .opacity),
                                removal: .opacity
                            ))
                    case .growthTracker:
                        growthTrackerView
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    case .ready:
                        readyView
                            .transition(.scale(scale: 0.95).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 450)
                
                Spacer()
                
                if phase == .ready && ctaVisible {
                    Button(action: {
                        Haptics.feedback(style: .medium)
                        router.navigate(.onboardingNotification)
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
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    Color.clear.frame(height: 86)
                }
            }
        }
        .onAppear {
            startCinematicSequence()
            Haptics.feedback(style: .light)
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .disableSwipeGesture()
    }
    
    func phaseIndex(_ p: CinematicPhase) -> Int {
        CinematicPhase.allCases.firstIndex(of: p) ?? 0
    }
    
    var scanningView: some View {
        VStack(spacing: 48) {
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color.black.opacity(0.06), lineWidth: 1.5)
                        .frame(width: CGFloat(140 + i * 45), height: CGFloat(140 + i * 45))
                        .scaleEffect(pulseRing ? 1.25 : 1.0)
                        .opacity(pulseRing ? 0 : 0.5)
                        .animation(
                            .easeOut(duration: 1.6)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.35),
                            value: pulseRing
                        )
                }
                
                Circle()
                    .trim(from: 0, to: CGFloat(scanPercent) / 100)
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 130, height: 130)
                    .rotationEffect(.degrees(-90))
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.08), radius: 24, y: 8)
                    .overlay(
                        Text("\(scanPercent)")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(.black) +
                        Text("%")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.black.opacity(0.4))
                    )
            }
            
            VStack(spacing: 12) {
                Text(scanText)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .contentTransition(.opacity)
                    .id(scanText)
                
                HStack(spacing: 5) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(Color.black)
                            .frame(width: 5, height: 5)
                            .opacity(currentScanIndex % 3 == i ? 1 : 0.2)
                    }
                }
            }
        }
        .padding(.horizontal, 40)
    }
    
    var threatsView: some View {
        VStack(spacing: 36) {
            VStack(spacing: 8) {
                Text("THREATS DETECTED")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(Color(hex: "FF6B6B"))
                
                Text("\(threatCount)")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .contentTransition(.numericText(value: Double(threatCount)))
            }
            
            VStack(spacing: 12) {
                ForEach(Array(threats.enumerated()), id: \.offset) { index, threat in
                    if threatsRevealed[index] {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(threat.2.opacity(0.12))
                                    .frame(width: 44, height: 44)
                                Image(systemName: threat.1)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(threat.2)
                            }
                            
                            Text(threat.0)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(threat.2)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
                        )
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9, anchor: .leading).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                }
            }
            .padding(.horizontal, 28)
        }
    }
    
    var aiDecoderView: some View {
        VStack(spacing: 28) {
            VStack(spacing: 6) {
                Text("🧠")
                    .font(.system(size: 40))
                Text("AI DECODER")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(.secondary)
            }
            
            ZStack {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Circle()
                            .fill(Color.black.opacity(0.08))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Text("Ex")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Your Ex")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                            Text("11:47 PM")
                                .font(.system(size: 11, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    Text(messageDecoded ? "I'm bored & lonely 🚩" : "I miss you...")
                        .font(.system(size: 26, weight: messageDecoded ? .black : .medium, design: .rounded))
                        .foregroundStyle(messageDecoded ? Color(hex: "EF4444") : .black)
                        .padding(.top, 4)
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: messageDecoded ? Color(hex: "EF4444").opacity(0.12) : .black.opacity(0.06), radius: 20, y: 8)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(messageDecoded ? Color(hex: "EF4444").opacity(0.25) : .clear, lineWidth: 2)
                )
                .scaleEffect(messageDecoded ? 1.02 : 1.0)
                .opacity(showMessage ? 1 : 0)
                .offset(y: showMessage ? 0 : 16)
                
                if messageScanned && !messageDecoded {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, Color(hex: "6366F1").opacity(0.4), Color(hex: "6366F1"), Color(hex: "6366F1").opacity(0.4), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 3)
                        .offset(y: scanLineOffset)
                        .blur(radius: 0.5)
                }
            }
            .padding(.horizontal, 28)
            
            if messageDecoded {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                    Text("Real meaning decoded")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(Color(hex: "22C55E"))
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    var panicShieldView: some View {
        VStack(spacing: 40) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "FF6B6B").opacity(0.25), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(chaosOpacity > 0.5 ? 1.15 : 0)
                    .opacity(chaosOpacity)
                
                if shieldPulse {
                    Circle()
                        .stroke(Color.black.opacity(0.15), lineWidth: 2)
                        .frame(width: 140, height: 140)
                        .scaleEffect(shieldPulse ? 1.5 : 1)
                        .opacity(shieldPulse ? 0 : 1)
                        .animation(.easeOut(duration: 1.0).repeatForever(autoreverses: false), value: shieldPulse)
                }
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 130, height: 130)
                    .shadow(color: .black.opacity(0.1), radius: 24, y: 10)
                    .overlay(
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 52, weight: .medium))
                            .foregroundStyle(.black)
                    )
                    .scaleEffect(shieldScale)
            }
            
            VStack(spacing: 8) {
                Text("PANIC SHIELD")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(blockedCount)")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .contentTransition(.numericText(value: Double(blockedCount)))
                    Text("urges blocked")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    var growthTrackerView: some View {
        VStack(spacing: 28) {
            VStack(spacing: 6) {
                Text("📈")
                    .font(.system(size: 40))
                Text("YOUR GLOW UP")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(.secondary)
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 20, y: 8)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Recovery Path")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                        Spacer()
                        Text("30 days")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    GeometryReader { geo in
                        let w = geo.size.width - 48
                        let h = geo.size.height
                        
                        ZStack {
                            Path { path in
                                path.move(to: CGPoint(x: 24, y: h * 0.8))
                                path.addCurve(
                                    to: CGPoint(x: 24 + w, y: h * 0.2),
                                    control1: CGPoint(x: 24 + w * 0.3, y: h * 0.9),
                                    control2: CGPoint(x: 24 + w * 0.7, y: h * 0.1)
                                )
                            }
                            .stroke(Color.black.opacity(0.06), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            
                            Path { path in
                                path.move(to: CGPoint(x: 24, y: h * 0.8))
                                path.addCurve(
                                    to: CGPoint(x: 24 + w, y: h * 0.2),
                                    control1: CGPoint(x: 24 + w * 0.3, y: h * 0.9),
                                    control2: CGPoint(x: 24 + w * 0.7, y: h * 0.1)
                                )
                            }
                            .trim(from: 0, to: pathProgress)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "8B5CF6"), Color(hex: "EC4899"), Color(hex: "F59E0B")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .shadow(color: Color(hex: "EC4899").opacity(0.3), radius: 6)
                            
                            let positions: [(x: CGFloat, y: CGFloat, label: String)] = [
                                (0.05, 0.75, "Start"),
                                (0.35, 0.55, "Week 1"),
                                (0.65, 0.35, "Week 2"),
                                (0.95, 0.22, "Free ✨")
                            ]
                            
                            ForEach(Array(positions.enumerated()), id: \.offset) { index, pos in
                                if milestones[index] {
                                    VStack(spacing: 4) {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 12, height: 12)
                                            .shadow(color: Color(hex: "EC4899").opacity(0.4), radius: 4)
                                            .overlay(
                                                Circle()
                                                    .fill(Color(hex: "EC4899"))
                                                    .frame(width: 6, height: 6)
                                            )
                                        
                                        Text(pos.label)
                                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                                            .foregroundStyle(.secondary)
                                    }
                                    .position(x: 24 + w * pos.x, y: h * pos.y)
                                    .transition(.scale.combined(with: .opacity))
                                }
                            }
                            
                            if sparklePhase {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 24))
                                    .foregroundStyle(Color(hex: "F59E0B"))
                                    .position(x: 24 + w * 0.92, y: h * 0.08)
                                    .symbolEffect(.variableColor.iterative.reversing, options: .repeating)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    .frame(height: 140)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 16)
                }
            }
            .frame(height: 210)
            .padding(.horizontal, 28)
        }
    }
    
    var readyView: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(Color(hex: "22C55E").opacity(0.1))
                    .frame(width: 160, height: 160)
                    .scaleEffect(readyScale)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 130, height: 130)
                    .shadow(color: Color(hex: "22C55E").opacity(0.2), radius: 24, y: 8)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 52, weight: .bold))
                            .foregroundStyle(Color(hex: "22C55E"))
                    )
                    .scaleEffect(readyScale)
            }
            .opacity(readyOpacity)
            
            VStack(spacing: 12) {
                Text("Ready.")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                
                Text("Your detox plan is built.")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .opacity(readyOpacity)
        }
    }
    
    private func startCinematicSequence() {
        pulseRing = true
        runScanningPhase()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                phase = .threats
            }
            Haptics.feedback(style: .medium)
            runThreatsPhase()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                phase = .aiDecoder
            }
            Haptics.feedback(style: .medium)
            runAIDecoderPhase()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 11.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                phase = .panicShield
            }
            Haptics.feedback(style: .medium)
            runPanicShieldPhase()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                phase = .growthTracker
            }
            Haptics.feedback(style: .medium)
            runGrowthTrackerPhase()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 19.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                phase = .ready
            }
            runReadyPhase()
        }
    }
    
    private func runScanningPhase() {
        Timer.scheduledTimer(withTimeInterval: 0.035, repeats: true) { timer in
            if scanPercent >= 100 {
                timer.invalidate()
                return
            }
            withAnimation(.linear(duration: 0.035)) {
                scanPercent += 1
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.55, repeats: true) { timer in
            if phase != .scanning {
                timer.invalidate()
                return
            }
            currentScanIndex = (currentScanIndex + 1) % scanTexts.count
            withAnimation(.easeInOut(duration: 0.25)) {
                scanText = scanTexts[currentScanIndex]
            }
        }
    }
    
    private func runThreatsPhase() {
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                    threatCount = i + 1
                    threatsRevealed[i] = true
                }
                Haptics.feedback(style: .light)
            }
        }
    }
    
    private func runAIDecoderPhase() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showMessage = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            messageScanned = true
            withAnimation(.easeInOut(duration: 1.0)) {
                scanLineOffset = 60
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                messageDecoded = true
            }
            Haptics.notification(type: .warning)
        }
    }
    
    private func runPanicShieldPhase() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                shieldScale = 1.0
            }
            Haptics.feedback(style: .heavy)
            
            withAnimation(.easeOut(duration: 0.6)) {
                chaosOpacity = 0
            }
            
            shieldPulse = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if blockedCount >= 47 || phase != .panicShield {
                    timer.invalidate()
                    return
                }
                withAnimation(.linear(duration: 0.1)) {
                    blockedCount += Int.random(in: 2...4)
                    if blockedCount > 47 { blockedCount = 47 }
                }
            }
        }
    }
    
    private func runGrowthTrackerPhase() {
        withAnimation(.easeInOut(duration: 1.8)) {
            pathProgress = 1.0
        }
        
        for i in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4 + 0.3) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                    milestones[i] = true
                }
                Haptics.feedback(style: .light)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.spring(response: 0.4)) {
                sparklePhase = true
            }
        }
    }
    
    private func runReadyPhase() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            readyScale = 1.0
            readyOpacity = 1.0
        }
        Haptics.notification(type: .success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                ctaVisible = true
            }
        }
    }
}

struct StoryProgressIndicator: View {
    let currentPhase: Int
    let totalPhases: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalPhases, id: \.self) { index in
                Capsule()
                    .fill(index <= currentPhase ? Color.black : Color.black.opacity(0.12))
                    .frame(height: 4)
                    .animation(.spring(response: 0.4), value: currentPhase)
            }
        }
    }
}

#Preview {
    OnboardingView3()
        .environment(Router())
}
