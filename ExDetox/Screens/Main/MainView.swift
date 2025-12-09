import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(NotificationStore.self) private var notificationStore
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedTab: Tab = .home
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(Tab.home)
                
                AnalyticsView()
                    .tag(Tab.analytics)
                
                AiAgentView()
                    .tag(Tab.aiAgent)
                
                MyWhyView()
                    .tag(Tab.myWhy)
                
                LearningView()
                    .tag(Tab.learning)
            }
            
            tabBarView()
        }
        .navigationBarBackButtonHidden()
        .disableSwipeGesture(id: "MainView")
        .onAppear {
            TrackingPersistence.bootstrap(store: trackingStore, context: modelContext)
        }
    }
    
    private func tabBarView() -> some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabItemView(for: tab)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Color(hex: "F5F0E8"))
    }
    
    private func tabItemView(for tab: Tab) -> some View {
        Button {
            selectedTab = tab
            Haptics.feedback(style: .light)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.unselectedIcon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(selectedTab == tab ? Color.primary : Color.primary.opacity(0.35))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

extension MainView {
    enum Tab: String, CaseIterable, Identifiable {
        var id: String { rawValue }
        
        case home
        case analytics
        case aiAgent
        case myWhy
        case learning
        
        var selectedIcon: String {
            switch self {
            case .home: return "house.fill"
            case .analytics: return "chart.bar.fill"
            case .aiAgent: return "message.fill"
            case .myWhy: return "heart.fill"
            case .learning: return "book.fill"
            }
        }
        
        var unselectedIcon: String {
            switch self {
            case .home: return "house"
            case .analytics: return "chart.bar"
            case .aiAgent: return "message"
            case .myWhy: return "heart"
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
                    UserProfileRecord.self,
                    WhyItemRecord.self
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
                    UserProfileRecord.self,
                    WhyItemRecord.self
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
                    UserProfileRecord.self,
                    WhyItemRecord.self
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
                    UserProfileRecord.self,
                    WhyItemRecord.self
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
