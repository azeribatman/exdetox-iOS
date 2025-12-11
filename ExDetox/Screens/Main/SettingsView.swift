import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(\.modelContext) private var modelContext
    @State private var showResetAlert = false
    @State private var showResetConfirmation = false
    @State private var showOpenSettingsAlert = false
    @State private var showStreakCelebration = false
    @State private var showExQuizSheet = false
    @State private var testQuizMessage: ExQuizMessage?
    @State private var debugStreakValue = 7
    
    private let notificationManager = LocalNotificationManager.shared
    
    var body: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        lifetimeStatsSection
                        notificationsSection
                        accountSection
                        legalSection
                        socialSection
                        supportSection
                        
                        #if DEBUG
                        debugSection
                        #endif
                        
                        versionFooter
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            
            if showStreakCelebration {
                StreakCelebrationView(
                    previousStreak: debugStreakValue - 1,
                    currentStreak: debugStreakValue,
                    onDismiss: {
                        withAnimation {
                            showStreakCelebration = false
                        }
                    }
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .alert("Reset Your Streak?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset Streak", role: .destructive) {
                TrackingPersistence.resetProgress(store: trackingStore, context: modelContext)
                Haptics.notification(type: .warning)
                showResetConfirmation = true
            }
        } message: {
            Text("This will reset your current streak to Day 1. Your lifetime stats (power action days, badges) will be preserved. You got this! 💪")
        }
        .alert("Streak Reset", isPresented: $showResetConfirmation) {
            Button("OK") { }
        } message: {
            Text("Your streak has been reset. Today is Day 1 of your new journey. We believe in you! ✨")
        }
        .alert("Enable Notifications", isPresented: $showOpenSettingsAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("To enable notifications, please go to Settings and allow notifications for ExDetox.")
        }
        .sheet(isPresented: $showExQuizSheet) {
            if let message = testQuizMessage {
                ExQuizSheetView(
                    message: message,
                    exName: userProfileStore.profile.exName,
                    onDismiss: {
                        showExQuizSheet = false
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            Task {
                await notificationManager.checkAuthorizationStatus()
            }
        }
    }
    
    private var notificationsSection: some View {
        SettingsSection(title: "NOTIFICATIONS") {
            SettingsToggleRow(
                icon: "message.fill",
                title: "Ex Quiz",
                subtitle: "Decode their manipulation",
                iconColor: Color(hex: "FF6B6B"),
                isOn: Binding(
                    get: { userProfileStore.profile.notificationPreferences.exQuizEnabled },
                    set: { newValue in
                        handleNotificationToggle(newValue) { granted in
                            userProfileStore.profile.notificationPreferences.exQuizEnabled = granted && newValue
                            if granted && newValue {
                                scheduleExQuizNotifications()
                            } else {
                                Task {
                                    await notificationManager.cancelNotifications(ofType: .exQuiz)
                                }
                            }
                        }
                    }
                )
            )
            
            SettingsDivider()
            
            SettingsToggleRow(
                icon: "flame.fill",
                title: "Streak Celebrations",
                subtitle: "Get hyped for milestones",
                iconColor: Color(hex: "FF9500"),
                isOn: Binding(
                    get: { userProfileStore.profile.notificationPreferences.streakCelebrationEnabled },
                    set: { newValue in
                        handleNotificationToggle(newValue) { granted in
                            userProfileStore.profile.notificationPreferences.streakCelebrationEnabled = granted && newValue
                            if granted && newValue {
                                scheduleStreakNotification()
                            } else {
                                Task {
                                    await notificationManager.cancelNotifications(ofType: .streakCelebration)
                                }
                            }
                        }
                    }
                )
            )
        }
    }
    
    private func handleNotificationToggle(_ newValue: Bool, completion: @escaping (Bool) -> Void) {
        if newValue {
            Task {
                await notificationManager.checkAuthorizationStatus()
                
                if notificationManager.authorizationStatus == .notDetermined {
                    let granted = await notificationManager.requestAuthorization()
                    await MainActor.run {
                        completion(granted)
                    }
                } else if notificationManager.authorizationStatus == .denied {
                    await MainActor.run {
                        showOpenSettingsAlert = true
                        completion(false)
                    }
                } else {
                    await MainActor.run {
                        completion(true)
                    }
                }
            }
        } else {
            completion(true)
        }
    }
    
    private func scheduleExQuizNotifications() {
        Task {
            await notificationManager.scheduleExQuizNotifications(
                exName: userProfileStore.profile.exName,
                exGender: userProfileStore.profile.exGender
            )
        }
    }
    
    private func scheduleStreakNotification() {
        Task {
            await notificationManager.scheduleStreakNotification(
                currentStreak: trackingStore.currentStreakDays
            )
        }
    }
    
    #if DEBUG
    private var debugSection: some View {
        SettingsSection(title: "🛠️ DEBUG MODE") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Current State")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Group {
                    debugInfoRow("Current Streak", "\(trackingStore.currentStreakDays) days")
                    debugInfoRow("Last Shown", "\(userProfileStore.profile.notificationPreferences.lastShownStreakDay) days")
                    debugInfoRow("Onboarding", userProfileStore.hasCompletedOnboarding ? "✅ Done" : "❌ Not done")
                    debugInfoRow("Ex Quiz", userProfileStore.profile.notificationPreferences.exQuizEnabled ? "✅ On" : "❌ Off")
                    debugInfoRow("Streak Notif", userProfileStore.profile.notificationPreferences.streakCelebrationEnabled ? "✅ On" : "❌ Off")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            
            SettingsDivider()
            
            SettingsRow(
                icon: "bell.badge.fill",
                title: "Test Ex Quiz Notification",
                subtitle: "Triggers in 3 seconds",
                iconColor: Color(hex: "FF6B6B")
            ) {
                Haptics.feedback(style: .medium)
                Task {
                    await notificationManager.triggerTestExQuizNotification(
                        exName: userProfileStore.profile.exName
                    )
                }
            }
            
            SettingsDivider()
            
            SettingsRow(
                icon: "flame.fill",
                title: "Test Streak Notification",
                subtitle: "Triggers in 3 seconds",
                iconColor: Color(hex: "FF9500")
            ) {
                Haptics.feedback(style: .medium)
                Task {
                    await notificationManager.triggerTestStreakNotification(
                        streak: trackingStore.currentStreakDays + 1
                    )
                }
            }
            
            SettingsDivider()
            
            VStack(spacing: 12) {
                HStack {
                    Text("Test Streak Celebration")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    
                    Spacer()
                    
                    Stepper("", value: $debugStreakValue, in: 1...365)
                        .labelsHidden()
                    
                    Text("Day \(debugStreakValue)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(width: 60)
                }
                
                Button(action: {
                    Haptics.feedback(style: .heavy)
                    withAnimation {
                        showStreakCelebration = true
                    }
                }) {
                    Text("Show Celebration")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "FF9500"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            
            SettingsDivider()
            
            SettingsRow(
                icon: "doc.text.magnifyingglass",
                title: "Test Ex Quiz Sheet",
                subtitle: "Show quiz interaction",
                iconColor: Color(hex: "6366F1")
            ) {
                Haptics.feedback(style: .medium)
                if let message = notificationManager.getMessage(byId: "msg_001") {
                    testQuizMessage = message
                    showExQuizSheet = true
                }
            }
            
            SettingsDivider()
            
            SettingsRow(
                icon: "arrow.clockwise",
                title: "Reset Last Shown Streak",
                subtitle: "Clears celebration state",
                iconColor: .gray
            ) {
                Haptics.feedback(style: .light)
                userProfileStore.profile.notificationPreferences.lastShownStreakDay = 0
            }
        }
    }
    
    private func debugInfoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
        }
    }
    #endif
    
    private var lifetimeStatsSection: some View {
        SettingsSection(title: "LIFETIME STATS") {
            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("\(trackingStore.maxStreak)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                    Text("best streak")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Rectangle()
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 1, height: 36)
                
                VStack(spacing: 4) {
                    Text("+\(String(format: "%.1f", trackingStore.lifetimeBonusDays))")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "34C759"))
                    Text("action days")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Rectangle()
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 1, height: 36)
                
                VStack(spacing: 4) {
                    Text("\(trackingStore.badges.count)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "FFD60A"))
                    Text("badges")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 16)
        }
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("SETTINGS")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundColor(.secondary)
                
                Text("Your space.")
                    .font(.system(size: 28, weight: .black, design: .rounded))
            }
            
            Spacer()
            
            Button(action: {
                Haptics.feedback(style: .light)
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private var accountSection: some View {
        SettingsSection(title: "ACCOUNT") {
            SettingsRow(
                icon: "arrow.counterclockwise",
                title: "Reset Streak",
                subtitle: "Start fresh (keeps lifetime stats)",
                iconColor: .orange
            ) {
                Haptics.feedback(style: .medium)
                showResetAlert = true
            }
            
            SettingsDivider()
            
            SettingsRow(
                icon: "shield.lefthalf.filled",
                title: "Content Blocking",
                subtitle: "Safari protection",
                iconColor: .blue
            ) {
                Haptics.feedback(style: .light)
            }
        }
    }
    
    private var legalSection: some View {
        SettingsSection(title: "LEGAL") {
            SettingsRow(
                icon: "hand.raised.fill",
                title: "Privacy Policy",
                iconColor: .gray
            ) {
                Haptics.feedback(style: .light)
            }
            
            SettingsDivider()
            
            SettingsRow(
                icon: "doc.text.fill",
                title: "Terms of Use",
                iconColor: .gray
            ) {
                Haptics.feedback(style: .light)
            }
        }
    }
    
    private var socialSection: some View {
        SettingsSection(title: "FOLLOW US") {
            SettingsRow(
                icon: "play.rectangle.fill",
                title: "TikTok",
                subtitle: "@exdetox",
                iconColor: .black
            ) {
                Haptics.feedback(style: .light)
            }
            
            SettingsDivider()
            
            SettingsRow(
                icon: "camera.fill",
                title: "Instagram",
                subtitle: "@exdetox",
                iconColor: .pink
            ) {
                Haptics.feedback(style: .light)
            }
        }
    }
    
    private var supportSection: some View {
        SettingsSection(title: "SUPPORT") {
            SettingsRow(
                icon: "star.fill",
                title: "Rate ExDetox",
                subtitle: "Help others heal",
                iconColor: .yellow
            ) {
                Haptics.feedback(style: .medium)
            }
            
            SettingsDivider()
            
            SettingsRow(
                icon: "envelope.fill",
                title: "Contact Us",
                subtitle: "We're here for you",
                iconColor: .purple
            ) {
                Haptics.feedback(style: .light)
            }
        }
    }
    
    private var versionFooter: some View {
        VStack(spacing: 8) {
            Text("ExDetox")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
            
            Text("Version 1.0.0")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.tertiary)
            
            Text("Made with 🫀 for the heartbroken")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.tertiary)
                .padding(.top, 4)
        }
        .padding(.top, 24)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.5)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.quaternary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(SettingsRowButtonStyle())
    }
}

struct SettingsRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.black.opacity(0.03) : Color.clear)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SettingsDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.black.opacity(0.05))
            .frame(height: 1)
            .padding(.leading, 68)
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let iconColor: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 38, height: 38)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(iconColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    SettingsView()
        .environment(TrackingStore.previewLevel2WithProgress)
        .environment(UserProfileStore())
        .modelContainer(for: [
            TrackingRecord.self,
            RelapseRecord.self,
            PowerActionObject.self,
            DailyCheckInRecord.self,
            BadgeRecord.self
        ], inMemory: true)
}
