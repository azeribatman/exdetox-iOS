import SwiftUI
import SwiftData

@main
struct ExDetoxApp: App {
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
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [configuration])
    }()
    
    @State private var router = Router.base
    @State private var trackingStore = TrackingStore()
    @State private var notificationStore = NotificationStore()
    @State private var userProfileStore = UserProfileStore()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.paths, root: root)
                .sheet(item: $router.sheet, content: sheet)
                .fullScreenCover(item: $router.fullScreenSheet, content: sheet)
                .environment(router)
                .environment(trackingStore)
                .environment(notificationStore)
                .environment(userProfileStore)
                .preferredColorScheme(.light)
                .modelContainer(sharedModelContainer)
        }
    }
    
    private func root() -> some View {
        LaunchView().withAppRouter()
    }
    
    private func sheet(for destination: RouterDestination) -> some View {
        RouterDestination.view(for: destination)
    }
}
