import SwiftUI

struct MeditateView: View {
    @Environment(\.dismiss) var dismiss
    @State private var textBuffer: String = ""
    @State private var showBurnAnimation = false
    @State private var showBreathingGame = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Text("Pause & Breathe")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Button(action: {
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
                .padding(.bottom, 10)
                .background(Color(hex: "F9F9F9"))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero Section
                        VStack(spacing: 12) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 60))
                                .foregroundStyle(.teal)
                                .padding()
                                .background(Color.teal.opacity(0.1))
                                .clipShape(Circle())
                            
                            Text("Center Yourself")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("Before you send that text, let's take a moment to breathe.")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                        }
                        .padding(.top, 10)
                        
                        // Quick Breathing Exercise
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Label("The 4-7-8 Breathing", systemImage: "wind")
                                    .font(.headline)
                                    .foregroundStyle(.teal)
                                Spacer()
                            }
                            
                            HStack(spacing: 20) {
                                BreathingStep(count: "4s", label: "Inhale")
                                BreathingStep(count: "7s", label: "Hold")
                                BreathingStep(count: "8s", label: "Exhale")
                            }
                            .frame(maxWidth: .infinity)
                            
                            Button(action: {
                                showBreathingGame = true
                            }) {
                                Text("Start Breathing Session")
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.teal)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        
                        // Write & Burn (Moved Up)
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Write & Burn", systemImage: "flame.fill")
                                .font(.headline)
                                .foregroundStyle(.red)
                            
                            Text("Type out what you want to say to them below, then burn it.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            if !showBurnAnimation {
                                TextEditor(text: $textBuffer)
                                    .frame(height: 100)
                                    .padding(8)
                                    .scrollContentBackground(.hidden) // Removes default background
                                    .background(Color(hex: "F2F2F7")) // Distinct background
                                    .cornerRadius(12)
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        showBurnAnimation = true
                                    }
                                    // Reset after animation
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        textBuffer = ""
                                        withAnimation {
                                            showBurnAnimation = false
                                        }
                                    }
                                }) {
                                    Text("Burn This Text 🔥")
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(textBuffer.isEmpty ? Color.gray : Color.red)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .disabled(textBuffer.isEmpty)
                            } else {
                                VStack {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 50))
                                        .foregroundStyle(.orange)
                                        .symbolEffect(.bounce, options: .repeating)
                                    
                                    Text("Burning away the urge...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(height: 160)
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        
                        // Reality Check
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Reality Check", systemImage: "checkmark.shield.fill")
                                .font(.headline)
                                .foregroundStyle(.orange)
                            
                            Text("Remember why you're here. Breaking no contact resets your healing process. Is a 2-minute conversation worth resetting 3 days of progress?")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .background(Color(hex: "F9F9F9").ignoresSafeArea())
            .sheet(isPresented: $showBreathingGame) {
                BreathingGameView()
            }
        }
    }
}

struct BreathingStep: View {
    let count: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(count)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.teal)
            
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.teal.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    MeditateView()
}
