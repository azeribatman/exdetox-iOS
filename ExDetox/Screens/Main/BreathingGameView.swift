import SwiftUI

struct BreathingGameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var breathingState: BreathingState = .idle
    @State private var timeRemaining: Int = 0
    @State private var timer: Timer?
    @State private var scale: CGFloat = 1.0
    @State private var message: String = "Tap Start to Begin"
    @State private var cycleCount: Int = 0
    
    private let creamBg = Color(hex: "F5F0E8")
    private let cardBg = Color(hex: "FFFDF9")
    
    enum BreathingState {
        case idle
        case inhale
        case hold
        case exhale
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("4-7-8 Breathing")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    
                    if cycleCount > 0 {
                        Text("Cycle \(cycleCount)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    stopBreathing()
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.primary.opacity(0.5))
                        .frame(width: 32, height: 32)
                        .background(cardBg)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Spacer()
            
            VStack(spacing: 40) {
                ZStack {
                    Circle()
                        .fill(Color.teal.opacity(0.08))
                        .frame(width: 280, height: 280)
                        .scaleEffect(scale)
                        .animation(.easeInOut(duration: animationDuration), value: scale)
                    
                    Circle()
                        .fill(Color.teal.opacity(0.15))
                        .frame(width: 220, height: 220)
                        .scaleEffect(scale * 0.9)
                        .animation(.easeInOut(duration: animationDuration), value: scale)
                    
                    Circle()
                        .fill(Color.teal)
                        .frame(width: 160, height: 160)
                        .scaleEffect(scale * 0.8)
                        .animation(.easeInOut(duration: animationDuration), value: scale)
                    
                    VStack(spacing: 6) {
                        Text(breathingState == .idle ? "🌬️" : "\(timeRemaining)")
                            .font(.system(size: breathingState == .idle ? 48 : 56, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText(value: Double(timeRemaining)))
                        
                        Text(message)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                
                if breathingState != .idle {
                    HStack(spacing: 20) {
                        phaseIndicator(phase: "Inhale", isActive: breathingState == .inhale, duration: "4s")
                        phaseIndicator(phase: "Hold", isActive: breathingState == .hold, duration: "7s")
                        phaseIndicator(phase: "Exhale", isActive: breathingState == .exhale, duration: "8s")
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                if breathingState == .idle {
                    Button(action: startBreathing) {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("Start Breathing")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.teal)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Text("Complete 3-4 cycles for best results")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                } else {
                    Button(action: stopBreathing) {
                        Text("Stop")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.red)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(creamBg.ignoresSafeArea())
    }
    
    private var animationDuration: Double {
        switch breathingState {
        case .inhale: return 4
        case .exhale: return 8
        default: return 0.3
        }
    }
    
    private func phaseIndicator(phase: String, isActive: Bool, duration: String) -> some View {
        VStack(spacing: 6) {
            Text(duration)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(isActive ? .teal : .secondary)
            
            Text(phase)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(isActive ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(isActive ? Color.teal.opacity(0.12) : cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
    
    func startBreathing() {
        stopTimer()
        scale = 1.0
        cycleCount = 0
        runInhale()
    }
    
    func stopBreathing() {
        stopTimer()
        breathingState = .idle
        message = "Tap Start to Begin"
        scale = 1.0
        timeRemaining = 0
        cycleCount = 0
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func runInhale() {
        breathingState = .inhale
        message = "Breathe In"
        timeRemaining = 4
        scale = 1.4
        cycleCount += 1
        
        startCountdown(duration: 4) {
            runHold()
        }
    }
    
    func runHold() {
        breathingState = .hold
        message = "Hold"
        timeRemaining = 7
        
        startCountdown(duration: 7) {
            runExhale()
        }
    }
    
    func runExhale() {
        breathingState = .exhale
        message = "Breathe Out"
        timeRemaining = 8
        scale = 1.0
        
        startCountdown(duration: 8) {
            runInhale()
        }
    }
    
    func startCountdown(duration: Int, completion: @escaping () -> Void) {
        timeRemaining = duration
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 1 {
                withAnimation {
                    timeRemaining -= 1
                }
            } else {
                timer?.invalidate()
                completion()
            }
        }
    }
}

#Preview {
    BreathingGameView()
}
