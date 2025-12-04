import SwiftUI

struct OnboardingView5: View {
    @Environment(Router.self) private var router
    @State private var isAnimating = false
    @State private var showContent = false
    @State private var rating = 0
    @State private var buttonScale: CGFloat = 1.0
    
    // Dynamic feedback based on rating
    var feedbackTitle: String {
        switch rating {
        case 1, 2: return "We'll do better! 🥺"
        case 3: return "Getting there! 😐"
        case 4: return "Almost perfect! 😮"
        case 5: return "Life Changer! 🤩"
        default: return "How excited are you?"
        }
    }
    
    var feedbackSubtitle: String {
        switch rating {
        case 1, 2: return "Tell us what's wrong."
        case 3: return "We're working on it."
        case 4: return "So close to freedom."
        case 5: return "You're ready to heal!"
        default: return "Rate your excitement level"
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            // Floating background elements
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .offset(x: -150, y: -200)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                
                Circle()
                    .fill(Color.indigo.opacity(0.1))
                    .frame(width: 250, height: 250)
                    .offset(x: 150, y: 100)
                    .scaleEffect(isAnimating ? 1.2 : 0.9)
            }
            .blur(radius: 30)
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Text("Before we start...")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(2)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : -10)
                        .animation(.easeOut(duration: 0.6), value: showContent)
                    
                    Text(feedbackTitle)
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .contentTransition(.numericText())
                        .padding(.horizontal)
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: showContent)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: rating)
                    
                    Text(feedbackSubtitle)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut.delay(0.2), value: showContent)
                }
                .padding(.top, 60)
                
                Spacer()
                

                // Rating Stars
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.system(size: 40))
                            .foregroundStyle(index <= rating ? Color.orange : Color.gray.opacity(0.3))
                            .scaleEffect(index == rating ? 1.5 : 1.0)
                            .rotationEffect(index == rating ? .degrees(15) : .degrees(0))
                            .shadow(color: index <= rating ? .orange.opacity(0.5) : .clear, radius: 10)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    rating = index
                                }
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                            }
                            .offset(y: showContent ? 0 : 50)
                            .opacity(showContent ? 1 : 0)
                            .animation(
                                .spring(response: 0.4, dampingFraction: 0.6)
                                .delay(Double(index) * 0.1 + 0.3),
                                value: showContent
                            )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 10)
                        .scaleEffect(showContent ? 1 : 0.5)
                        .opacity(showContent ? 1 : 0)
                )
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: showContent)
                
                Spacer()

                
                Spacer()
                
                // Continue Button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        buttonScale = 0.95
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            buttonScale = 1.0
                        }
                    }
                    router.set(.main)
                }) {
                    HStack {
                        Text("See My Plan")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .scaleEffect(buttonScale)
                .offset(y: showContent ? 0 : 100)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: showContent)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .disableSwipeGesture()
    }
}

#Preview {
    OnboardingView5()
}

