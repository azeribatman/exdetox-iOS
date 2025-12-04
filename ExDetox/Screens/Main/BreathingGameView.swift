import SwiftUI

struct BreathingGameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var breathingState: BreathingState = .idle
    @State private var timeRemaining: Int = 0
    @State private var timer: Timer?
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.5
    @State private var message: String = "Tap Start to Begin"
    
    enum BreathingState {
        case idle
        case inhale
        case hold
        case exhale
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Text("4-7-8 Breathing 🌬️")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        stopBreathing()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                Spacer()
                
                // Game Content
                VStack(spacing: 40) {
                    // Visualizer
                    ZStack {
                        // Outer Glow
                        Circle()
                            .fill(Color.teal.opacity(0.2))
                            .frame(width: 300, height: 300)
                            .scaleEffect(scale)
                            .animation(.easeInOut(duration: breathingState == .inhale ? 4 : (breathingState == .exhale ? 8 : 0)), value: scale)
                        
                        // Core Circle
                        Circle()
                            .fill(Color.teal)
                            .frame(width: 200, height: 200)
                            .scaleEffect(scale * 0.8)
                            .shadow(color: .teal.opacity(0.5), radius: 20, x: 0, y: 0)
                            .animation(.easeInOut(duration: breathingState == .inhale ? 4 : (breathingState == .exhale ? 8 : 0)), value: scale)
                        
                        // Text
                        VStack(spacing: 8) {
                            Text(breathingState == .idle ? "Ready?" : "\(timeRemaining)")
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .contentTransition(.numericText(value: Double(timeRemaining)))
                            
                            Text(message)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }
                    .frame(height: 350)
                    
                    // Instructions / Controls
                    if breathingState == .idle {
                        Button(action: startBreathing) {
                            Text("Start Breathing")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.teal)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .teal.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 40)
                    } else {
                        Button(action: stopBreathing) {
                            Text("Stop")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.red)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 12)
                                .background(Color.red.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                
                Spacer()
            }
            .background(Color(hex: "F9F9F9").ignoresSafeArea())
        }
    }
    
    func startBreathing() {
        // Reset
        stopTimer()
        scale = 1.0
        
        // Start Cycle
        runInhale()
    }
    
    func stopBreathing() {
        stopTimer()
        breathingState = .idle
        message = "Tap Start to Begin"
        scale = 1.0
        timeRemaining = 0
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func runInhale() {
        breathingState = .inhale
        message = "Inhale..."
        timeRemaining = 4
        scale = 1.5 // Expand
        
        startCountdown(duration: 4) {
            runHold()
        }
    }
    
    func runHold() {
        breathingState = .hold
        message = "Hold..."
        timeRemaining = 7
        // Scale stays same
        
        startCountdown(duration: 7) {
            runExhale()
        }
    }
    
    func runExhale() {
        breathingState = .exhale
        message = "Exhale..."
        timeRemaining = 8
        scale = 1.0 // Contract
        
        startCountdown(duration: 8) {
            runInhale() // Loop
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


