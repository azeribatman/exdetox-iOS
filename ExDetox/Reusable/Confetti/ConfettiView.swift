import SwiftUI

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let emoji: String
    let rotation: Double
    let scale: CGFloat
    var opacity: Double
}

struct ConfettiModifier: ViewModifier {
    @Binding var counter: Int
    let emojis: [String]
    let particleCount: Int
    
    @State private var pieces: [ConfettiPiece] = []
    @State private var isAnimating = false
    
    init(counter: Binding<Int>, emojis: [String] = ["🎉", "✨", "💪", "🔥"], particleCount: Int = 50) {
        self._counter = counter
        self.emojis = emojis
        self.particleCount = particleCount
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            GeometryReader { geo in
                ForEach(pieces) { piece in
                    Text(piece.emoji)
                        .font(.system(size: 24 * piece.scale))
                        .position(x: piece.x, y: piece.y)
                        .rotationEffect(.degrees(piece.rotation))
                        .opacity(piece.opacity)
                }
            }
            .allowsHitTesting(false)
        }
        .onChange(of: counter) { _, _ in
            triggerConfetti()
        }
    }
    
    private func triggerConfetti() {
        guard !isAnimating else { return }
        isAnimating = true
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let centerX = screenWidth / 2
        let centerY = screenHeight / 2
        
        var newPieces: [ConfettiPiece] = []
        
        for _ in 0..<particleCount {
            let piece = ConfettiPiece(
                x: centerX,
                y: centerY,
                emoji: emojis.randomElement() ?? "🎉",
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.8...1.5),
                opacity: 1.0
            )
            newPieces.append(piece)
        }
        
        pieces = newPieces
        
        withAnimation(.easeOut(duration: 0.8)) {
            for i in pieces.indices {
                let angle = Double.random(in: 0...(2 * .pi))
                let distance = CGFloat.random(in: 100...300)
                pieces[i].x += cos(angle) * distance
                pieces[i].y += sin(angle) * distance - CGFloat.random(in: 50...150)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 1.5)) {
                for i in pieces.indices {
                    pieces[i].y += CGFloat.random(in: 200...400)
                    pieces[i].opacity = 0
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            pieces = []
            isAnimating = false
        }
    }
}

extension View {
    func confettiCannon(
        counter: Binding<Int>,
        num: Int = 50,
        confettis: [ConfettiType] = [.text("🎉"), .text("✨")],
        confettiSize: CGFloat = 25,
        openingAngle: Angle = Angle(degrees: 0),
        closingAngle: Angle = Angle(degrees: 360),
        radius: CGFloat = 200
    ) -> some View {
        let emojis = confettis.compactMap { type -> String? in
            if case .text(let emoji) = type {
                return emoji
            }
            return nil
        }
        
        return self.modifier(ConfettiModifier(counter: counter, emojis: emojis, particleCount: num))
    }
}

enum ConfettiType {
    case text(String)
}
