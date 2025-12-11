import SwiftUI
import SwiftData

struct ScreenshotsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TrackingRecord.self,
            RelapseRecord.self,
            PowerActionObject.self,
            DailyCheckInRecord.self,
            BadgeRecord.self,
            UserProfileRecord.self,
            WhyItemRecord.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @State private var trackingStore = TrackingStore.previewLevel2WithProgress
    @State private var notificationStore = NotificationStore()
    @State private var userProfileStore = UserProfileStore.previewProfile()
    
    var body: some Scene {
        WindowGroup {
            ScreenshotsView()
                .environment(trackingStore)
                .environment(notificationStore)
                .environment(userProfileStore)
                .preferredColorScheme(.light)
                .modelContainer(sharedModelContainer)
        }
    }
}

extension UserProfileStore {
    static func previewProfile() -> UserProfileStore {
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
            onboardingCompletedDate: Date(),
            notificationPreferences: .defaults
        )
        return store
    }
}
