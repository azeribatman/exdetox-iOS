import SwiftUI
import StoreKit

struct OnboardingView5: View {
    @Environment(Router.self) private var router
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(\.requestReview) private var requestReview
    
    @State private var showContent = false
    @State private var rating = 0
    @State private var floatOffset: CGFloat = 0
    
    var feedbackEmoji: String {
        switch rating {
        case 1: return "😔"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "😊"
        case 5: return "🔥"
        default: return "✨"
        }
    }
    
    var feedbackTitle: String {
        switch rating {
        case 1, 2: return "We'll prove\nyou wrong."
        case 3: return "Fair enough."
        case 4: return "Almost there."
        case 5: return "Let's go."
        default: return "One last thing."
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 32) {
                    if showContent {
                        Text(feedbackEmoji)
                            .font(.system(size: 70))
                            .offset(y: floatOffset)
                            .transition(.scale.combined(with: .opacity))
                            .id(feedbackEmoji)
                    }
                    
                    VStack(spacing: 12) {
                        if showContent {
                            Text(feedbackTitle)
                                .font(.system(size: 42, weight: .black, design: .rounded))
                                .multilineTextAlignment(.center)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .id(feedbackTitle)
                        }
                        
                        if showContent && rating == 0 {
                            Text("How ready are you to\nmove on?")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .transition(.opacity)
                        }
                    }
                }
                
                Spacer()
                
                if showContent {
                    HStack(spacing: 16) {
                        ForEach(1...5, id: \.self) { index in
                            Button(action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                                    rating = index
                                }
                                Haptics.feedback(style: .medium)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    navigateToNext()
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(index <= rating ? Color.black : Color.white)
                                        .frame(width: 56, height: 56)
                                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                                    
                                    Text("\(index)")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(index <= rating ? .white : .black)
                                }
                            }
                            .scaleEffect(index == rating ? 1.15 : 1.0)
                            .offset(y: showContent ? 0 : 40)
                            .opacity(showContent ? 1 : 0)
                            .animation(
                                .spring(response: 0.4, dampingFraction: 0.7)
                                .delay(Double(index) * 0.08 + 0.3),
                                value: showContent
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                Spacer()
                
                if showContent {
                    Button(action: {
                        Haptics.feedback(style: .medium)
                        navigateToNext()
                    }) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 50)
                    .offset(y: showContent ? 0 : 30)
                    .opacity(showContent ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.8), value: showContent)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
            Haptics.feedback(style: .light)
            startFloating()
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .disableSwipeGesture()
    }
    
    private func startFloating() {
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            floatOffset = 12
        }
    }
    
    private func navigateToNext() {
        userProfileStore.profile.excitementRating = rating
        router.navigate(.onboarding4)
        
        if rating >= 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                requestReview()
            }
        }
    }
}

#Preview {
    OnboardingView5()
        .environment(Router.base)
        .environment(UserProfileStore())
}
