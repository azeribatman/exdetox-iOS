import SwiftUI

struct RoastMeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var roastMessage: String = ""
    @State private var animate = false
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    // Savage roasts list
    private let roasts = [
        "He's not 'finding himself', he's finding someone else to manipulate. 🚩",
        "Your ex is like a software update: annoying, unnecessary, and makes everything slower. 🐌",
        "If he was a spice, he'd be flour. 🍞",
        "Checking his story won't change the ending, sweetie. 📖",
        "You dropped this 👑. Now pick it up and block him.",
        "He’s probably wearing that same hoodie he hasn't washed in 3 weeks. 🤢",
        "The only thing he committed to was being a disappointment. 📉",
        "You miss the idea of him, not the clown who forgot your birthday. 🤡",
        "His new girl isn't competition, she's the next victim. 🕵️‍♀️",
        "Remember when you thought he was 'The One'? Yeah, we all make mistakes. 😂",
        "He's a 10? But he texts his ex? He's a -2. 📉",
        "Crying over him? dehydration is not a good look. 💧",
        "He’s living rent-free in your head. Evict him. 🏠🚫",
        "If he wanted to, he would. He didn't. End of story. 🤷‍♀️",
        "Trash takes itself out. Don't go dumpster diving. 🗑️"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Text("Roast Me 🔥")
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
                .padding(.bottom, 20)
                
                Spacer()
                
                // Content
                ZStack {
                    // Animated Background Elements
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 300, height: 300)
                        .scaleEffect(animate ? 1.2 : 0.8)
                        .opacity(animate ? 0.5 : 0.2)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
                    
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 250, height: 250)
                        .offset(x: animate ? 20 : -20, y: animate ? -20 : 20)
                        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animate)
                    
                    VStack(spacing: 30) {
                        // Emoji Icon
                        Text("💀")
                            .font(.system(size: 80))
                            .rotationEffect(.degrees(rotation))
                            .scaleEffect(scale)
                            .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0), value: rotation)
                        
                        // Roast Text
                        Text(roastMessage)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                            )
                            .padding(.horizontal, 20)
                            .transition(.scale.combined(with: .opacity))
                            .id(roastMessage) // Forces transition on change
                        
                        // Action Button
                        Button(action: generateRoast) {
                            HStack {
                                Image(systemName: "flame.fill")
                                Text("Cook Me Again")
                            }
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                    }
                }
                
                Spacer()
            }
            .background(Color(hex: "F9F9F9").ignoresSafeArea())
            .onAppear {
                generateRoast()
                animate = true
            }
        }
    }
    
    private func generateRoast() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        // Animation trigger
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            rotation += 360
            scale = 1.2
        }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
            scale = 1.0
        }
        
        // Pick a random roast
        var newRoast = roasts.randomElement() ?? "You're doing great! (Just kidding, block him)"
        while newRoast == roastMessage {
            newRoast = roasts.randomElement() ?? "You're doing great!"
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            roastMessage = newRoast
        }
    }
}

#Preview {
    RoastMeView()
}

