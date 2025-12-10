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
        
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            print("Failed to create ModelContainer: \(error)")
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dbPath = documentsPath.appendingPathComponent("default.store")
            
            try? FileManager.default.removeItem(at: dbPath)
            
            do {
                return try ModelContainer(for: schema, configurations: [configuration])
            } catch {
                fatalError("Could not create ModelContainer even after clearing data: \(error)")
            }
        }
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
