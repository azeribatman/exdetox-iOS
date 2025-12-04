import SwiftUI

struct MainView: View {
    @State private var selectedTab: Tab = .home
    @State private var whyItems: [WhyItem] = [
        WhyItem(title: "He never listened to me when I was crying."),
        WhyItem(title: "Forgot my birthday... again.", imageName: "photo"),
        WhyItem(title: "Gaslighting 101.")
    ]
    private let tabBarHeight: CGFloat = 72
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(Tab.home)
                
                AnalyticsView()
                    .tag(Tab.analytics)
                
                AiAgentView()
                    .tag(Tab.aiAgent)
                
                MyWhyView(items: $whyItems)
                    .tag(Tab.myWhy)
                
                LearningView()
                    .tag(Tab.learning)
            }
            .padding(.bottom, tabBarHeight)
            .overlay(alignment: .bottom) {
                tabBar()
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private func tabBar() -> some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 24))
                            .symbolVariant(selectedTab == tab ? .fill : .none)
                            .foregroundStyle(selectedTab == tab ? .black : Color.gray.opacity(0.5))
                        
                        Text(tab.title)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(selectedTab == tab ? .black : Color.gray.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 4) // Adjust for safe area if needed, usually handled by background
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 0) // SafeArea automatically adds padding to the background
        .background(Color.white.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.gray.opacity(0.1))
        }
    }
    
    enum Tab: String, CaseIterable {
        case home
        case analytics
        case aiAgent
        case myWhy
        case learning
        
        var title: String {
            switch self {
            case .home: return "Home"
            case .analytics: return "Analytics"
            case .aiAgent: return "AI Agent"
            case .myWhy: return "My Why"
            case .learning: return "Learning"
            }
        }
        
        var iconName: String {
            switch self {
            case .home: return "house"
            case .analytics: return "chart.bar"
            case .aiAgent: return "brain.head.profile"
            case .myWhy: return "heart.slash" // or list.bullet.clipboard or similar
            case .learning: return "book"
            }
        }
    }
}

#Preview {
    MainView()
}

