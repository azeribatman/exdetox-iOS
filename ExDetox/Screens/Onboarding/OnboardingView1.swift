import SwiftUI

struct OnboardingView1: View {
    @State private var currentPage = 0
    
    // Grid animation states
    @State private var animateGrid = false
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Freedom",
            subtitle: "The ultimate breakup detox companion. Stay strong, stay no-contact, and reclaim your life.",
            icon: "heart.slash.fill",
            color: .pink
        ),
        OnboardingPage(
            title: "Don't Panic",
            subtitle: "About to text them? Hit the Panic Button instead. We'll talk you out of it.",
            icon: "exclamationmark.triangle.fill",
            color: .orange
        ),
        OnboardingPage(
            title: "Your Glow Up Era",
            subtitle: "Track your healing, build new habits, and become the best version of yourself.",
            icon: "sparkles",
            color: .indigo
        )
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Animated Background Grid (Fixed at top)
                ZStack {
                    // Background Gradients/Shapes
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        
                        // Floating cards/grid elements
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(0..<12, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                pages[currentPage].color.opacity(0.3),
                                                pages[currentPage].color.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(height: index % 2 == 0 ? 100 : 140)
                                    .offset(y: animateGrid ? 0 : (index % 2 == 0 ? -20 : 20))
                                    .animation(
                                        Animation.easeInOut(duration: 3)
                                            .repeatForever(autoreverses: true)
                                            .delay(Double(index) * 0.1),
                                        value: animateGrid
                                    )
                            }
                        }
                        .rotationEffect(.degrees(-10))
                        .scaleEffect(1.2)
                        .offset(y: -50)
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.45)
                .mask(
                    LinearGradient(colors: [.black, .black, .clear], startPoint: .top, endPoint: .bottom)
                )
                .ignoresSafeArea()
                
                Spacer()
            }
            
            // Content
            VStack(spacing: 0) {
                Spacer()
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 400)
                
                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.black : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.bottom, 32)
                
                // Action Button
                Button(action: {
                    withAnimation {
                        if currentPage < pages.count - 1 {
                            currentPage += 1
                        } else {

                        }
                    }
                }) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
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
                .padding(.bottom, 20) // Safe area padding handled by layout, but extra space feels nice
            }
            
            // Floating Icon in the middle transition
            GeometryReader { geo in
                VStack {
                    Spacer()
                        .frame(height: geo.size.height * 0.35) // Position overlaps with grid bottom
                    
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 100, height: 100)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: pages[currentPage].icon)
                                .font(.system(size: 40))
                                .foregroundColor(pages[currentPage].color)
                                .transition(.scale.combined(with: .opacity))
                                .id("icon-\(currentPage)") // Force transition
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            animateGrid = true
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text(page.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
            
            Text(page.subtitle)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
                .lineSpacing(4)
            
            Spacer()
        }
        .padding(.top, 60) // Make room for the floating icon
    }
}

#Preview {
    OnboardingView1()
}

