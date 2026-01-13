#if DEBUG
import SwiftUI
import UIKit

struct ShakeDetector: UIViewRepresentable {
    let onShake: () -> Void
    
    func makeUIView(context: Context) -> ShakeDetectingView {
        let view = ShakeDetectingView()
        view.onShake = onShake
        return view
    }
    
    func updateUIView(_ uiView: ShakeDetectingView, context: Context) {
        uiView.onShake = onShake
    }
}

class ShakeDetectingView: UIView {
    var onShake: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isUserInteractionEnabled = true
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        becomeFirstResponder()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            onShake?()
        }
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.background(
            ShakeDetector(onShake: action)
                .frame(width: 0, height: 0)
        )
    }
}
#endif
