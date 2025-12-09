import SwiftUI

struct MeditateView: View {
    @Environment(\.dismiss) var dismiss
    @State private var textBuffer: String = ""
    @State private var showBurnAnimation = false
    @State private var showBreathingGame = false
    
    private let creamBg = Color(hex: "F5F0E8")
    private let cardBg = Color(hex: "FFFDF9")
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Pause & Breathe")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                Spacer()
                
                Button(action: { dismiss() }) {
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
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    VStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.teal.opacity(0.12))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundStyle(.teal)
                        }
                        
                        Text("Center Yourself")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        
                        Text("Before you send that text, let's take a moment to breathe.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "wind")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.teal)
                            
                            Text("The 4-7-8 Breathing")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        
                        HStack(spacing: 10) {
                            BreathingStep(count: "4s", label: "Inhale", color: .teal)
                            BreathingStep(count: "7s", label: "Hold", color: .teal)
                            BreathingStep(count: "8s", label: "Exhale", color: .teal)
                        }
                        
                        Button(action: { showBreathingGame = true }) {
                            HStack(spacing: 10) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Start Breathing Session")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    .padding(18)
                    .background(cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 8) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.orange)
                            
                            Text("Write & Burn")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        
                        Text("Type what you want to say to them, then burn it away.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        if !showBurnAnimation {
                            TextEditor(text: $textBuffer)
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .frame(height: 100)
                                .padding(12)
                                .scrollContentBackground(.hidden)
                                .background(creamBg)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showBurnAnimation = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    textBuffer = ""
                                    withAnimation {
                                        showBurnAnimation = false
                                    }
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("Burn This Text")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(textBuffer.isEmpty ? Color.primary.opacity(0.2) : Color.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .disabled(textBuffer.isEmpty)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.orange)
                                    .symbolEffect(.bounce, options: .repeating)
                                
                                Text("Burning away the urge...")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(height: 150)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(18)
                    .background(cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.purple)
                            
                            Text("Reality Check")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        
                        Text("Breaking no contact resets your healing. Is a 2-minute conversation worth days of progress?")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .background(creamBg.ignoresSafeArea())
        .sheet(isPresented: $showBreathingGame) {
            BreathingGameView()
        }
    }
}

struct BreathingStep: View {
    let count: String
    let label: String
    var color: Color = .teal
    
    var body: some View {
        VStack(spacing: 6) {
            Text(count)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    MeditateView()
}
