import SwiftUI
import SwiftData
import UserNotifications
import SuperwallKit
import AppsFlyerLib
import AppTrackingTransparency

@main
struct ExDetoxApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TrackingRecord.self,
            RelapseRecord.self,
            PowerActionObject.self,
            DailyCheckInRecord.self,
            BadgeRecord.self,
            UserProfileRecord.self,
            WhyItemRecord.self,
            LearningProgressRecord.self
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
    @State private var hasRunIntegrityCheck = false
    @State private var showStreakCelebration = false
    @State private var pendingQuizMessage: ExQuizMessage?
    @State private var previousStreakForCelebration = 0
    @State private var pendingStreakCelebration = false
    @Environment(\.scenePhase) private var scenePhase
    
    private let notificationManager = LocalNotificationManager.shared
    
    init() {
        AppsFlyerLib.shared().appsFlyerDevKey = "42Lv7YCLa6d23HZsjVAnBP"
        AppsFlyerLib.shared().appleAppID = "6756420232"
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        
        ATTrackingManager.requestTrackingAuthorization { (status) in
            switch status {
            case .denied:
                print("AuthorizationSatus is denied")
            case .notDetermined:
                print("AuthorizationSatus is notDetermined")
            case .restricted:
                print("AuthorizationSatus is restricted")
            case .authorized:
                print("AuthorizationSatus is authorized")
            @unknown default:
                fatalError("Invalid authorization status")
            }
        }
        
        AppsFlyerLib.shared().start()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationStack(path: $router.paths, root: root)
                    .sheet(item: $router.sheet, content: sheet)
                    .fullScreenCover(item: $router.fullScreenSheet, content: sheet)
                    .environment(router)
                    .environment(trackingStore)
                    .environment(notificationStore)
                    .environment(userProfileStore)
                    .preferredColorScheme(.light)
                    .modelContainer(sharedModelContainer)
                    .task {
                        await runStartupIntegrityCheck()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .exQuizNotificationTapped)) { notification in
                        handleExQuizNotification(notification)
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .streakNotificationTapped)) { _ in
                        pendingStreakCelebration = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            checkAndShowStreakCelebration(force: true)
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .checkStreakCelebration)) { _ in
                        checkAndShowStreakCelebration(force: false)
                    }
                    .onChange(of: scenePhase) { oldPhase, newPhase in
                        if newPhase == .active {
                            if pendingStreakCelebration {
                                pendingStreakCelebration = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    checkAndShowStreakCelebration(force: true)
                                }
                            }
                            rescheduleNotificationsIfNeeded()
                        }
                    }
                    .task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        
                        if let pendingType = AppDelegate.pendingNotificationType {
                            print("🔔 Processing pending notification: \(pendingType.rawValue)")
                            AppDelegate.pendingNotificationType = nil
                            
                            switch pendingType {
                            case .exQuiz:
                                if let userInfo = AppDelegate.pendingNotificationUserInfo {
                                    NotificationCenter.default.post(
                                        name: .exQuizNotificationTapped,
                                        object: nil,
                                        userInfo: userInfo
                                    )
                                }
                            case .streakCelebration:
                                checkAndShowStreakCelebration(force: true)
                            }
                            AppDelegate.pendingNotificationUserInfo = nil
                        }
                    }
                
                if showStreakCelebration {
                    StreakCelebrationView(
                        previousStreak: previousStreakForCelebration,
                        currentStreak: trackingStore.currentStreakDays,
                        onDismiss: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                showStreakCelebration = false
                            }
                            userProfileStore.profile.notificationPreferences.lastShownStreakDay = trackingStore.currentStreakDays
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity
                    ))
                    .zIndex(100)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showStreakCelebration)
            .sheet(item: $pendingQuizMessage) { message in
                ExQuizSheetView(
                    message: message,
                    exName: userProfileStore.profile.exName,
                    onDismiss: {
                        pendingQuizMessage = nil
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .preferredColorScheme(.light)
        }
    }
    
    private func root() -> some View {
        LaunchView().withAppRouter()
    }
    
    private func sheet(for destination: RouterDestination) -> some View {
        RouterDestination.view(for: destination)
    }
    
    @MainActor
    private func runStartupIntegrityCheck() async {
        guard !hasRunIntegrityCheck else { return }
        hasRunIntegrityCheck = true
        
        let context = sharedModelContainer.mainContext
        TrackingPersistence.runIntegrityCheck(context: context)
    }
    
    private func handleExQuizNotification(_ notification: Notification) {
        print("🔔 Handling ex quiz notification")
        
        guard let messageId = notification.userInfo?["messageId"] as? String else {
            print("🔔 No messageId in notification, using random message")
            if let fallbackMessage = notificationManager.getRandomMessage() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    pendingQuizMessage = fallbackMessage
                }
            }
            return
        }
        
        print("🔔 Looking for message: \(messageId)")
        
        guard let message = notificationManager.getMessage(byId: messageId) else {
            print("🔔 Message not found, trying to get any message")
            if let fallbackMessage = notificationManager.getRandomMessage() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    pendingQuizMessage = fallbackMessage
                }
            }
            return
        }
        
        print("🔔 Found message: \(message.text)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            pendingQuizMessage = message
        }
    }
    
    private func checkAndShowStreakCelebration(force: Bool = false) {
        guard !showStreakCelebration else {
            print("🔔 Streak celebration skipped: already showing")
            return
        }
        guard userProfileStore.hasCompletedOnboarding else {
            print("🔔 Streak celebration skipped: onboarding not completed")
            return
        }
        
        let currentStreak = trackingStore.currentStreakDays
        let lastShownStreak = userProfileStore.profile.notificationPreferences.lastShownStreakDay
        
        print("🔔 Checking streak celebration: current=\(currentStreak), lastShown=\(lastShownStreak), force=\(force)")
        
        guard currentStreak > 0 else {
            print("🔔 Streak celebration skipped: streak is 0")
            return
        }
        
        if currentStreak > lastShownStreak {
            previousStreakForCelebration = lastShownStreak > 0 ? lastShownStreak : max(currentStreak - 1, 0)
            
            print("🔔 Showing streak celebration! previous=\(previousStreakForCelebration), current=\(currentStreak)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showStreakCelebration = true
                }
            }
        } else if force && currentStreak > 0 {
            previousStreakForCelebration = max(currentStreak - 1, 0)
            
            print("🔔 Force showing streak celebration! previous=\(previousStreakForCelebration), current=\(currentStreak)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showStreakCelebration = true
                }
            }
        }
    }
    
    private func rescheduleNotificationsIfNeeded() {
        guard userProfileStore.hasCompletedOnboarding else { return }
        
        let prefs = userProfileStore.profile.notificationPreferences
        
        if prefs.exQuizEnabled {
            Task {
                await notificationManager.scheduleExQuizNotifications(
                    exName: userProfileStore.profile.exName,
                    exGender: userProfileStore.profile.exGender
                )
            }
        }
        
        if prefs.streakCelebrationEnabled {
            Task {
                await notificationManager.scheduleStreakNotification(
                    currentStreak: trackingStore.currentStreakDays
                )
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    static var pendingNotificationType: NotificationType?
    static var pendingNotificationUserInfo: [AnyHashable: Any]?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        Superwall.configure(apiKey: "pk_UVy__-LmdHBZflLIZ7SfN")
        Superwall.shared.delegate = SuperwallAnalyticsDelegate.shared
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        guard let typeString = userInfo["type"] as? String,
              let type = NotificationType(rawValue: typeString) else {
            return
        }
        
        print("🔔 Notification tapped: \(type.rawValue)")
        
        AppDelegate.pendingNotificationType = type
        AppDelegate.pendingNotificationUserInfo = userInfo
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            switch type {
            case .exQuiz:
                NotificationCenter.default.post(
                    name: .exQuizNotificationTapped,
                    object: nil,
                    userInfo: userInfo
                )
            case .streakCelebration:
                NotificationCenter.default.post(
                    name: .streakNotificationTapped,
                    object: nil,
                    userInfo: userInfo
                )
            }
        }
    }
}

extension Notification.Name {
    static let exQuizNotificationTapped = Notification.Name("exQuizNotificationTapped")
    static let streakNotificationTapped = Notification.Name("streakNotificationTapped")
    static let checkStreakCelebration = Notification.Name("checkStreakCelebration")
}
