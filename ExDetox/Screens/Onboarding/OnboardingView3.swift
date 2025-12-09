import SwiftUI

struct OnboardingView3: View {
    @Environment(Router.self) private var router
    
    enum CinematicPhase: CaseIterable {
        case scanning
        case threats
        case aiDecoder
        case panicShield
        case growthTracker
        case planCard
        case ready
    }
    
    @State private var phase: CinematicPhase = .scanning
    
    @State private var scanPercent: Int = 0
    @State private var scanText = "Initializing..."
    @State private var scanTexts = [
        "Scanning message history...",
        "Detecting emotional patterns...",
        "Analyzing attachment style...",
        "Mapping vulnerability points...",
        "Processing behavioral data...",
        "Compiling recovery profile..."
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
    
    @State private var cardVisible = false
    @State private var cardScale: CGFloat = 0.9
    
    @State private var readyScale: CGFloat = 0.8
    @State private var readyOpacity: Double = 0
    @State private var ctaVisible = false
    
    private let softBackground = Color(hex: "F9F9F9")
    private let accentBlack = Color.black
    
    var body: some View {
        ZStack {
            softBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                phaseIndicator
                    .padding(.top, 70)
                
                Spacer()
                
                ZStack {
                    switch phase {
                    case .scanning:
                        scanningView
                            .transition(.asymmetric(
                                insertion: .opacity,
                                removal: .scale(scale: 1.2).combined(with: .opacity)
                            ))
                    case .threats:
                        threatsView
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.9).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    case .aiDecoder:
                        aiDecoderView
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .scale(scale: 0.95).combined(with: .opacity)
                            ))
                    case .panicShield:
                        panicShieldView
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .opacity
                            ))
                    case .growthTracker:
                        growthTrackerView
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .scale(scale: 1.05).combined(with: .opacity)
                            ))
                    case .planCard:
                        planCardView
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.9).combined(with: .opacity),
                                removal: .opacity
                            ))
                    case .ready:
                        readyView
                            .transition(.scale(scale: 0.9).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 420)
                
                Spacer()
                
                if phase == .ready && ctaVisible {
                    ctaButton
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 50)
                } else {
                    Color.clear.frame(height: 80)
                }
            }
        }
        .onAppear {
            startCinematicSequence()
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .disableSwipeGesture()
    }
    
    var phaseIndicator: some View {
        HStack(spacing: 6) {
            ForEach(Array(CinematicPhase.allCases.enumerated()), id: \.offset) { index, p in
                Capsule()
                    .fill(phaseIndex(phase) >= index ? accentBlack : accentBlack.opacity(0.15))
                    .frame(width: phaseIndex(phase) == index ? 28 : 8, height: 4)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: phase)
            }
        }
    }
    
    func phaseIndex(_ p: CinematicPhase) -> Int {
        CinematicPhase.allCases.firstIndex(of: p) ?? 0
    }
    
    var scanningView: some View {
        VStack(spacing: 40) {
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(accentBlack.opacity(0.08), lineWidth: 1.5)
                        .frame(width: CGFloat(160 + i * 50), height: CGFloat(160 + i * 50))
                        .scaleEffect(pulseRing ? 1.3 : 1.0)
                        .opacity(pulseRing ? 0 : 0.6)
                        .animation(
                            .easeOut(duration: 1.8)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.4),
                            value: pulseRing
                        )
                }
                
                Circle()
                    .trim(from: 0, to: CGFloat(scanPercent) / 100)
                    .stroke(accentBlack, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 130, height: 130)
                    .shadow(color: .black.opacity(0.06), radius: 20, y: 8)
                    .overlay(
                        VStack(spacing: 4) {
                            Text("\(scanPercent)")
                                .font(.system(size: 44, weight: .black, design: .rounded))
                                .foregroundStyle(accentBlack)
                                .contentTransition(.numericText(value: Double(scanPercent)))
                            Text("%")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(accentBlack.opacity(0.4))
                        }
                    )
            }
            
            VStack(spacing: 16) {
                Text(scanText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(accentBlack.opacity(0.6))
                    .contentTransition(.opacity)
                    .id(scanText)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 6) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(accentBlack)
                            .frame(width: 5, height: 5)
                            .opacity(currentScanIndex % 3 == i ? 1 : 0.2)
                    }
                }
            }
        }
        .padding(.horizontal, 40)
    }
    
    var threatsView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("THREATS DETECTED")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(Color(hex: "FF6B6B"))
                
                Text("\(threatCount)")
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .foregroundStyle(accentBlack)
                    .contentTransition(.numericText(value: Double(threatCount)))
            }
            
            VStack(spacing: 14) {
                ForEach(Array(threats.enumerated()), id: \.offset) { index, threat in
                    if threatsRevealed[index] {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(threat.2.opacity(0.12))
                                    .frame(width: 48, height: 48)
                                Image(systemName: threat.1)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(threat.2)
                            }
                            
                            Text(threat.0)
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundStyle(accentBlack)
                            
                            Spacer()
                            
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(threat.2)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
                        )
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.85, anchor: .leading).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                }
            }
            .padding(.horizontal, 32)
        }
    }
    
    var aiDecoderView: some View {
        VStack(spacing: 28) {
            HStack(spacing: 10) {
                Image(systemName: "brain")
                    .font(.system(size: 18, weight: .semibold))
                Text("AI DECODER")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .tracking(2)
            }
            .foregroundStyle(Color(hex: "6366F1"))
            
            ZStack {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Circle()
                            .fill(accentBlack.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .overlay(Text("Ex").font(.system(size: 13, weight: .bold)).foregroundStyle(accentBlack.opacity(0.6)))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Your Ex")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(accentBlack)
                            Text("11:47 PM")
                                .font(.system(size: 12))
                                .foregroundStyle(accentBlack.opacity(0.4))
                        }
                        
                        Spacer()
                    }
                    
                    Text(messageDecoded ? "I'm bored & lonely 🚩" : "I miss you...")
                        .font(.system(size: 24, weight: messageDecoded ? .bold : .medium, design: .rounded))
                        .foregroundStyle(messageDecoded ? Color(hex: "EF4444") : accentBlack)
                        .padding(.top, 4)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: messageDecoded ? Color(hex: "EF4444").opacity(0.15) : .black.opacity(0.06), radius: 20, y: 8)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(messageDecoded ? Color(hex: "EF4444").opacity(0.3) : .clear, lineWidth: 2)
                )
                .scaleEffect(messageDecoded ? 1.02 : 1.0)
                .opacity(showMessage ? 1 : 0)
                .offset(y: showMessage ? 0 : 20)
                
                if messageScanned && !messageDecoded {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, Color(hex: "6366F1").opacity(0.5), Color(hex: "6366F1"), Color(hex: "6366F1").opacity(0.5), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 4)
                        .offset(y: scanLineOffset)
                        .blur(radius: 1)
                }
            }
            .padding(.horizontal, 32)
            
            if messageDecoded {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                    Text("Translation complete")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Color(hex: "22C55E"))
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    var panicShieldView: some View {
        VStack(spacing: 36) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "FF6B6B").opacity(0.3), Color(hex: "FF6B6B").opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(chaosOpacity > 0.5 ? 1.2 : 0)
                    .opacity(chaosOpacity)
                
                if shieldPulse {
                    Circle()
                        .stroke(accentBlack.opacity(0.2), lineWidth: 3)
                        .frame(width: 160, height: 160)
                        .scaleEffect(shieldPulse ? 1.6 : 1)
                        .opacity(shieldPulse ? 0 : 1)
                        .animation(.easeOut(duration: 1.2).repeatForever(autoreverses: false), value: shieldPulse)
                }
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 140, height: 140)
                    .shadow(color: .black.opacity(0.1), radius: 25, y: 10)
                    .overlay(
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 56, weight: .medium))
                            .foregroundStyle(accentBlack)
                    )
                    .scaleEffect(shieldScale)
            }
            
            VStack(spacing: 10) {
                Text("PANIC MODE ACTIVATED")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(accentBlack.opacity(0.5))
                
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(blockedCount)")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .contentTransition(.numericText(value: Double(blockedCount)))
                    Text("urges blocked")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(accentBlack.opacity(0.6))
                }
                .foregroundStyle(accentBlack)
            }
        }
    }
    
    var growthTrackerView: some View {
        VStack(spacing: 28) {
            HStack(spacing: 10) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 18, weight: .semibold))
                Text("YOUR GLOW UP")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .tracking(2)
            }
            .foregroundStyle(Color(hex: "22C55E"))
            
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 20, y: 8)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Recovery Progress")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(accentBlack)
                        Spacer()
                        Text("30 days")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(accentBlack.opacity(0.4))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    ZStack {
                        Path { path in
                            path.move(to: CGPoint(x: 24, y: 130))
                            path.addCurve(
                                to: CGPoint(x: 296, y: 30),
                                control1: CGPoint(x: 80, y: 150),
                                control2: CGPoint(x: 200, y: 20)
                            )
                        }
                        .stroke(accentBlack.opacity(0.08), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        
                        Path { path in
                            path.move(to: CGPoint(x: 24, y: 130))
                            path.addCurve(
                                to: CGPoint(x: 296, y: 30),
                                control1: CGPoint(x: 80, y: 150),
                                control2: CGPoint(x: 200, y: 20)
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
                        .shadow(color: Color(hex: "EC4899").opacity(0.3), radius: 8)
                        
                        let positions: [(x: CGFloat, y: CGFloat, label: String)] = [
                            (40, 125, "Day 1"),
                            (115, 105, "Week 1"),
                            (210, 55, "Week 2"),
                            (280, 35, "Free ✨")
                        ]
                        
                        ForEach(Array(positions.enumerated()), id: \.offset) { index, pos in
                            if milestones[index] {
                                VStack(spacing: 6) {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 14, height: 14)
                                        .shadow(color: Color(hex: "EC4899").opacity(0.4), radius: 6)
                                        .overlay(
                                            Circle()
                                                .fill(Color(hex: "EC4899"))
                                                .frame(width: 8, height: 8)
                                        )
                                    
                                    Text(pos.label)
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .foregroundStyle(accentBlack.opacity(0.6))
                                }
                                .position(x: pos.x, y: pos.y + 10)
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        
                        if sparklePhase {
                            Image(systemName: "sparkles")
                                .font(.system(size: 28))
                                .foregroundStyle(Color(hex: "F59E0B"))
                                .position(x: 295, y: 15)
                                .symbolEffect(.variableColor.iterative.reversing, options: .repeating)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(height: 170)
                    .padding(.horizontal, 8)
                }
            }
            .frame(height: 230)
            .padding(.horizontal, 32)
        }
    }
    
    var planCardView: some View {
        VStack(spacing: 24) {
            Text("YOUR DETOX PLAN")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(3)
                .foregroundStyle(accentBlack.opacity(0.5))
            
            VStack(spacing: 0) {
                VStack(spacing: 20) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "8B5CF6"), Color(hex: "EC4899")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(spacing: 8) {
                        Text("30-Day Detox")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(accentBlack)
                        
                        Text("Your personalized recovery journey")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(accentBlack.opacity(0.5))
                    }
                }
                .padding(.top, 28)
                .padding(.bottom, 24)
                
                Divider()
                    .padding(.horizontal, 24)
                
                HStack(spacing: 0) {
                    VStack(spacing: 6) {
                        Text("START")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.5)
                            .foregroundStyle(accentBlack.opacity(0.4))
                        Text(formattedDate(Date()))
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(accentBlack)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Rectangle()
                        .fill(accentBlack.opacity(0.1))
                        .frame(width: 1, height: 40)
                    
                    VStack(spacing: 6) {
                        Text("TARGET")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.5)
                            .foregroundStyle(accentBlack.opacity(0.4))
                        Text(formattedDate(Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()))
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(hex: "22C55E"))
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 20)
                
                Divider()
                    .padding(.horizontal, 24)
                
                HStack(spacing: 24) {
                    PlanStatItem(icon: "brain.head.profile", value: "AI", label: "Decoder")
                    PlanStatItem(icon: "shield.fill", value: "24/7", label: "Protection")
                    PlanStatItem(icon: "chart.line.uptrend.xyaxis", value: "Daily", label: "Tracking")
                }
                .padding(.vertical, 20)
            }
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 30, y: 12)
            )
            .scaleEffect(cardScale)
            .opacity(cardVisible ? 1 : 0)
            .padding(.horizontal, 32)
        }
    }
    
    var readyView: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(Color(hex: "22C55E").opacity(0.1))
                    .frame(width: 180, height: 180)
                    .scaleEffect(readyScale)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 140, height: 140)
                    .shadow(color: Color(hex: "22C55E").opacity(0.25), radius: 25, y: 8)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 56, weight: .bold))
                            .foregroundStyle(Color(hex: "22C55E"))
                    )
                    .scaleEffect(readyScale)
            }
            .opacity(readyOpacity)
            
            VStack(spacing: 14) {
                Text("You're All Set")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(accentBlack)
                
                Text("Your personalized detox plan is ready")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(accentBlack.opacity(0.5))
            }
            .opacity(readyOpacity)
        }
    }
    
    var ctaButton: some View {
        Button(action: {
            Haptics.notification(type: .success)
            router.navigate(.onboarding5)
        }) {
            HStack(spacing: 12) {
                Text("Start My Detox")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(accentBlack)
            )
            .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
        }
        .padding(.horizontal, 32)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func startCinematicSequence() {
        pulseRing = true
        
        runScanningPhase()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                phase = .threats
            }
            runThreatsPhase()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                phase = .aiDecoder
            }
            runAIDecoderPhase()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 13.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                phase = .panicShield
            }
            runPanicShieldPhase()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 17.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                phase = .growthTracker
            }
            runGrowthTrackerPhase()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 22.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                phase = .planCard
            }
            runPlanCardPhase()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 27.0) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                phase = .ready
            }
            runReadyPhase()
        }
    }
    
    private func runScanningPhase() {
        Timer.scheduledTimer(withTimeInterval: 0.045, repeats: true) { timer in
            if scanPercent >= 100 {
                timer.invalidate()
                return
            }
            withAnimation(.linear(duration: 0.045)) {
                scanPercent += 1
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { timer in
            if phase != .scanning {
                timer.invalidate()
                return
            }
            currentScanIndex = (currentScanIndex + 1) % scanTexts.count
            withAnimation(.easeInOut(duration: 0.3)) {
                scanText = scanTexts[currentScanIndex]
            }
        }
    }
    
    private func runThreatsPhase() {
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.6) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    threatCount = i + 1
                    threatsRevealed[i] = true
                }
                Haptics.feedback(style: .medium)
            }
        }
    }
    
    private func runAIDecoderPhase() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showMessage = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            messageScanned = true
            withAnimation(.easeInOut(duration: 1.2)) {
                scanLineOffset = 60
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                messageDecoded = true
            }
            Haptics.notification(type: .warning)
        }
    }
    
    private func runPanicShieldPhase() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.55)) {
                shieldScale = 1.0
            }
            Haptics.feedback(style: .heavy)
            
            withAnimation(.easeOut(duration: 0.8)) {
                chaosOpacity = 0
            }
            
            shieldPulse = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { timer in
                if blockedCount >= 47 || phase != .panicShield {
                    timer.invalidate()
                    return
                }
                withAnimation(.linear(duration: 0.12)) {
                    blockedCount += Int.random(in: 2...5)
                    if blockedCount > 47 { blockedCount = 47 }
                }
            }
        }
    }
    
    private func runGrowthTrackerPhase() {
        withAnimation(.easeInOut(duration: 2.2)) {
            pathProgress = 1.0
        }
        
        for i in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5 + 0.4) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                    milestones[i] = true
                }
                Haptics.feedback(style: .light)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.spring(response: 0.5)) {
                sparklePhase = true
            }
        }
    }
    
    private func runPlanCardPhase() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                cardVisible = true
                cardScale = 1.0
            }
            Haptics.notification(type: .success)
        }
    }
    
    private func runReadyPhase() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
            readyScale = 1.0
            readyOpacity = 1.0
        }
        Haptics.notification(type: .success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                ctaVisible = true
            }
        }
    }
}

struct PlanStatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.7))
            
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.black)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.black.opacity(0.4))
        }
    }
}

#Preview {
    OnboardingView3()
        .environment(Router())
}
