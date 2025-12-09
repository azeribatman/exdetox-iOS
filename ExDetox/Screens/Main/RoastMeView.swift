import SwiftUI

struct RoastMeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var roastMessage: String = ""
    @State private var emojiScale: CGFloat = 1.0
    @State private var emojiRotation: Double = 0
    @State private var cardOffset: CGFloat = 0
    @State private var showContent = false
    
    private let roasts = [
        "He's not 'finding himself', he's finding someone else to manipulate. 🚩",
        "Your ex is like a software update: annoying, unnecessary, and makes everything slower. 🐌",
        "If he was a spice, he'd be flour. 🍞",
        "Checking his story won't change the ending, sweetie. 📖",
        "You dropped this 👑. Now pick it up and block him.",
        "He's probably wearing that same hoodie he hasn't washed in 3 weeks. 🤢",
        "The only thing he committed to was being a disappointment. 📉",
        "You miss the idea of him, not the clown who forgot your birthday. 🤡",
        "His new girl isn't competition, she's the next victim. 🕵️‍♀️",
        "Remember when you thought he was 'The One'? Yeah, we all make mistakes. 😂",
        "He's a 10? But he texts his ex? He's a -2. 📉",
        "Crying over him? Dehydration is not a good look. 💧",
        "He's living rent-free in your head. Evict him. 🏠",
        "If he wanted to, he would. He didn't. End of story. 🤷‍♀️",
        "Trash takes itself out. Don't go dumpster diving. 🗑️"
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                Spacer()
                
                contentView
                
                Spacer()
                
                actionButton
            }
        }
        .onAppear {
            generateRoast()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showContent = true
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("REALITY CHECK")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundColor(.secondary)
                
                Text("Roast Me")
                    .font(.system(size: 28, weight: .black, design: .rounded))
            }
            
            Spacer()
            
            Button(action: {
                Haptics.feedback(style: .light)
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.06))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 12)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : -20)
    }
    
    private var contentView: some View {
        VStack(spacing: 32) {
            Text("🔥")
                .font(.system(size: 72))
                .scaleEffect(emojiScale)
                .rotationEffect(.degrees(emojiRotation))
                .shadow(color: .orange.opacity(0.3), radius: 20, x: 0, y: 10)
            
            roastCard
        }
        .opacity(showContent ? 1 : 0)
        .scaleEffect(showContent ? 1 : 0.9)
    }
    
    private var roastCard: some View {
        VStack(spacing: 0) {
            Text(roastMessage)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .lineSpacing(6)
                .padding(.horizontal, 28)
                .padding(.vertical, 32)
                .id(roastMessage)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
        .padding(.horizontal, 24)
        .offset(y: cardOffset)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 0.95).combined(with: .opacity)
        ))
    }
    
    private var actionButton: some View {
        Button(action: generateRoast) {
            HStack(spacing: 10) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Cook Me Again")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 30)
    }
    
    private func generateRoast() {
        Haptics.feedback(style: .heavy)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            emojiScale = 1.3
            emojiRotation += 15
        }
        
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6).delay(0.1)) {
            emojiScale = 0.9
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7).delay(0.2)) {
            emojiScale = 1.0
        }
        
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            cardOffset = -8
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.15)) {
            cardOffset = 0
        }
        
        var newRoast = roasts.randomElement() ?? "You're doing great! (Just kidding, block him)"
        while newRoast == roastMessage && roasts.count > 1 {
            newRoast = roasts.randomElement() ?? "You're doing great!"
        }
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            roastMessage = newRoast
        }
    }
}

#Preview {
    RoastMeView()
}
