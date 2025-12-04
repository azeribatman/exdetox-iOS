import SwiftUI

struct OnboardingView4: View {
    @State private var isAnimating = false
    @State private var showContent = false
    @State private var userCount = 0
    @State private var activeReviewIndex = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    // Fake Reviews Data
    let reviews = [
        Review(name: "Sarah K.", text: "I finally stopped stalking his IG. This app is a lifesaver! 🙏", stars: 5),
        Review(name: "Mike T.", text: "The panic button actually works. Haven't texted her in 3 weeks.", stars: 5),
        Review(name: "Jessica L.", text: "My glow up is real. Thank you ExDetox! ✨", stars: 5),
        Review(name: "David R.", text: "Best breakup buddy ever. Better than therapy.", stars: 5),
        Review(name: "Emily W.", text: "I feel like myself again. 10/10 recommend.", stars: 5)
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            Text("We prepared a personal plan for you")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.top, 40)
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                            
                            // 100k Users Badge with "Wheats" (Laurels)
                            ZStack {
                                HStack(spacing: 20) {
                                    Image(systemName: "laurel.leading")
                                        .font(.system(size: 60))
                                        .foregroundColor(.orange)
                                        .rotationEffect(.degrees(isAnimating ? 5 : -5))
                                    
                                    VStack(spacing: 4) {
                                        Text("\(userCount, format: .number)+")
                                            .font(.title)
                                            .fontWeight(.black)
                                            .monospacedDigit()
                                            .contentTransition(.numericText(value: Double(userCount)))
                                        Text("Healed Users")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.secondary)
                                            .textCase(.uppercase)
                                    }
                                    
                                    Image(systemName: "laurel.trailing")
                                        .font(.system(size: 60))
                                        .foregroundColor(.orange)
                                        .rotationEffect(.degrees(isAnimating ? -5 : 5))
                                }
                                .scaleEffect(isAnimating ? 1.05 : 0.95)
                            }
                            .padding(.vertical, 20)
                            .opacity(showContent ? 1 : 0)
                            .scaleEffect(showContent ? 1 : 0.8)
                        }
                        
                        // Fake Reviews Carousel
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Real Stories")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 24)
                            .opacity(showContent ? 1 : 0)
                            .offset(x: showContent ? 0 : -20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(Array(reviews.enumerated()), id: \.element.name) { index, review in
                                        ReviewCard(review: review)
                                            .offset(x: showContent ? 0 : 100)
                                            .opacity(showContent ? 1 : 0)
                                            .animation(
                                                .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)
                                                .delay(Double(index) * 0.1 + 0.5),
                                                value: showContent
                                            )
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        
                        // Plan Preview
                        VStack(spacing: 20) {
                            Text("Your Plan Includes:")
                                .font(.title3)
                                .fontWeight(.bold)
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                                .animation(.easeOut.delay(0.8), value: showContent)
                            
                            VStack(spacing: 0) {
                                PlanItemRow(icon: "brain.head.profile", title: "AI Relationship Coach", subtitle: "24/7 Support", color: .indigo, delay: 0.9)
                                Divider().padding(.leading, 60)
                                PlanItemRow(icon: "heart.slash.fill", title: "No-Contact Tracker", subtitle: "Stay strong", color: .pink, delay: 1.0)
                                Divider().padding(.leading, 60)
                                PlanItemRow(icon: "sparkles", title: "Daily Glow-Up Tasks", subtitle: "Focus on you", color: .orange, delay: 1.1)
                            }
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                            .padding(.horizontal, 24)
                            .offset(y: showContent ? 0 : 50)
                            .opacity(showContent ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: showContent)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
                
                // Footer / CTA
                VStack {
                    Button(action: {
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }) {
                        HStack {
                            Text("Start My Healing Journey")
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
                        .scaleEffect(isAnimating ? 1.02 : 1.0)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    .padding(.top, 10)
                    .background(
                        LinearGradient(colors: [Color(hex: "F9F9F9").opacity(0), Color(hex: "F9F9F9")], startPoint: .top, endPoint: .bottom)
                    )
                    .offset(y: showContent ? 0 : 100)
                    .opacity(showContent ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.2), value: showContent)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            // Animate number
            let duration: TimeInterval = 2.0
            let steps = 50
            let stepDuration = duration / Double(steps)
            for i in 0...steps {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDuration) {
                    withAnimation(.default) {
                        userCount = Int(Double(i) / Double(steps) * 100000)
                    }
                }
            }
        }
    }
}

struct Review {
    let name: String
    let text: String
    let stars: Int
}

struct ReviewCard: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 4) {
                ForEach(0..<review.stars, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
            
            Text(review.text)
                .font(.subheadline)
                .lineLimit(3)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 24, height: 24)
                    .overlay(Text(review.name.prefix(1)).font(.caption).bold().foregroundColor(.gray))
                
                Text(review.name)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 10))
            }
        }
        .padding(16)
        .frame(width: 220, height: 160)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct PlanItemRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    var delay: Double = 0
    
    @State private var showCheck = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title3)
                .scaleEffect(showCheck ? 1 : 0.001)
                .opacity(showCheck ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay), value: showCheck)
        }
        .padding(16)
        .onAppear {
            showCheck = true
        }
    }
}

#Preview {
    OnboardingView4()
}

