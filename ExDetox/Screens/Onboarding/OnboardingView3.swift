import SwiftUI

struct OnboardingView3: View {
    @Environment(Router.self) private var router
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    let features: [FeaturePage] = [
        FeaturePage(
            title: "AI Relationship Coach",
            subtitle: "Get 24/7 analysis of your texts. We'll tell you if it's a trap or if you should actually reply (spoiler: probably not).",
            image: "brain.head.profile",
            color: .indigo
        ),
        FeaturePage(
            title: "The Panic Button",
            subtitle: "About to break no-contact? Hit the button. We'll simulate a best friend slapping the phone out of your hand.",
            image: "exclamationmark.shield.fill",
            color: .pink
        ),
        FeaturePage(
            title: "Healing Timeline",
            subtitle: "Visualize your recovery. See exactly when you'll stop crying in the shower and start thriving.",
            image: "chart.line.uptrend.xyaxis",
            color: .orange
        )
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(features[currentPage].color.opacity(0.1))
                        .frame(width: 300, height: 300)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Circle()
                        .fill(features[currentPage].color.opacity(0.2))
                        .frame(width: 200, height: 200)
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
                        .animation(.easeInOut(duration: 2).delay(0.5).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Image(systemName: features[currentPage].image)
                        .font(.system(size: 80))
                        .foregroundColor(features[currentPage].color)
                        .symbolEffect(.bounce, value: currentPage)
                        .transition(.scale.combined(with: .opacity))
                        .id("icon-\(currentPage)")
                }
                .frame(height: UIScreen.main.bounds.height * 0.4)
                .padding(.top, 40)
                
                TabView(selection: $currentPage) {
                    ForEach(0..<features.count, id: \.self) { index in
                        FeaturePageView(feature: features[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                Spacer()
                
                VStack(spacing: 24) {
                    HStack(spacing: 8) {
                        ForEach(0..<features.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? features[currentPage].color : Color.gray.opacity(0.3))
                                .frame(width: currentPage == index ? 24 : 8, height: 8)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            if currentPage < features.count - 1 {
                                currentPage += 1
                            } else {
                                router.navigate(.onboarding4)
                            }
                        }
                    }) {
                        Text(currentPage == features.count - 1 ? "Start My Detox" : "Tell Me More")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(features[currentPage].color)
                            .cornerRadius(16)
                            .shadow(color: features[currentPage].color.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            isAnimating = true
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .disableSwipeGesture()
    }
}

struct FeaturePage {
    let title: String
    let subtitle: String
    let image: String
    let color: Color
}

struct FeaturePageView: View {
    let feature: FeaturePage
    
    var body: some View {
        VStack(spacing: 16) {
            Text(feature.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            Text(feature.subtitle)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
                .lineSpacing(4)
        }
    }
}

#Preview {
    OnboardingView3()
        .environment(Router.base)
}
