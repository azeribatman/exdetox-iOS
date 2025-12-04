import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(NotificationStore.self) private var notificationStore
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(\.modelContext) private var modelContext
    
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
        .overlay(alignment: .top) {
            NotificationBannerView()
                .padding(.top, 4)
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            TrackingPersistence.bootstrap(store: trackingStore, context: modelContext)
        }
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
                    .padding(.bottom, 4)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 0)
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
            case .myWhy: return "heart.slash"
            case .learning: return "book"
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView()
                .environment(TrackingStore.previewNewUser)
                .environment(NotificationStore())
                .environment(previewUserProfile())
                .modelContainer(for: [
                    TrackingRecord.self,
                    RelapseRecord.self,
                    PowerActionObject.self,
                    DailyCheckInRecord.self,
                    BadgeRecord.self,
                    UserProfileRecord.self
                ], inMemory: true)
                .previewDisplayName("New User")
            
            MainView()
                .environment(TrackingStore.previewLevel2WithProgress)
                .environment(NotificationStore())
                .environment(previewUserProfile())
                .modelContainer(for: [
                    TrackingRecord.self,
                    RelapseRecord.self,
                    PowerActionObject.self,
                    DailyCheckInRecord.self,
                    BadgeRecord.self,
                    UserProfileRecord.self
                ], inMemory: true)
                .previewDisplayName("Level 2 Progress")
            
            MainView()
                .environment(TrackingStore.previewLevel3WithRelapses)
                .environment(NotificationStore())
                .environment(previewUserProfile())
                .modelContainer(for: [
                    TrackingRecord.self,
                    RelapseRecord.self,
                    PowerActionObject.self,
                    DailyCheckInRecord.self,
                    BadgeRecord.self,
                    UserProfileRecord.self
                ], inMemory: true)
                .previewDisplayName("Level 3 With Relapses")
            
            MainView()
                .environment(TrackingStore.previewLevel5)
                .environment(NotificationStore())
                .environment(previewUserProfile())
                .modelContainer(for: [
                    TrackingRecord.self,
                    RelapseRecord.self,
                    PowerActionObject.self,
                    DailyCheckInRecord.self,
                    BadgeRecord.self,
                    UserProfileRecord.self
                ], inMemory: true)
                .previewDisplayName("Level 5 Unbothered")
        }
    }
    
    static func previewUserProfile() -> UserProfileStore {
        let store = UserProfileStore()
        store.profile = UserProfile(
            name: "Sarah",
            gender: "Female",
            exName: "Jake",
            exGender: "Male",
            relationshipDuration: "1 - 3 years",
            breakupInitiator: "They did (Their loss)",
            contactStatus: "No Contact (Clean streak)",
            socialMediaHabits: "Muted but looking",
            sleepQuality: "Tossing & turning",
            mood: "Okay-ish 😐",
            excitementRating: 4,
            onboardingCompletedDate: Date()
        )
        return store
    }
}
