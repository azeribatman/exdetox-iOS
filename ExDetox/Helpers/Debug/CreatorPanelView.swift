#if DEBUG
import SwiftUI
import UserNotifications

struct CreatorPanelView: View {
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var exName: String = ""
    @State private var yourName: String = ""
    @State private var daysToSet: String = ""
    @State private var notificationTitle: String = ""
    @State private var notificationBody: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let creamBg = Color(hex: "F5F0E8")
    private let cardBg = Color(hex: "FFFDF9")
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    profileSection
                    daysSection
                    notificationSection
                }
                .padding(16)
            }
            .background(creamBg.ignoresSafeArea())
            .navigationTitle("Creator Panel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                exName = userProfileStore.profile.exName
                yourName = userProfileStore.profile.name
                daysToSet = "\(trackingStore.currentStreakDays)"
            }
            .alert("Creator Panel", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PROFILE SETTINGS")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your Name")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    
                    TextField("Enter your name", text: $yourName)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(creamBg)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Ex's Name")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    
                    TextField("Enter ex's name", text: $exName)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(creamBg)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Button {
                    applyProfileChanges()
                } label: {
                    Text("Apply Profile Changes")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(16)
            .background(cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var daysSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("STREAK SETTINGS")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Days (Current: \(trackingStore.currentStreakDays))")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    
                    TextField("Enter days", text: $daysToSet)
                        .textFieldStyle(.plain)
                        .keyboardType(.numberPad)
                        .padding(12)
                        .background(creamBg)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Button {
                    applyDaysChange()
                } label: {
                    Text("Set Days")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(16)
            .background(cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TEST NOTIFICATION")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Title")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    
                    TextField("Notification title", text: $notificationTitle)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(creamBg)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Body")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    
                    TextField("Notification body", text: $notificationBody)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(creamBg)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Button {
                    sendTestNotification()
                } label: {
                    Text("Send Test Notification")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(16)
            .background(cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private func applyProfileChanges() {
        userProfileStore.profile.name = yourName
        userProfileStore.profile.exName = exName
        trackingStore.state.exName = exName
        
        alertMessage = "Profile updated!\nYour Name: \(yourName)\nEx's Name: \(exName)"
        showingAlert = true
    }
    
    private func applyDaysChange() {
        guard let days = Int(daysToSet), days >= 0 else {
            alertMessage = "Please enter a valid number of days"
            showingAlert = true
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        if let newStartDate = calendar.date(byAdding: .day, value: -(days - 1), to: now) {
            trackingStore.state.noContactStartDate = newStartDate
            trackingStore.state.programStartDate = newStartDate
            trackingStore.state.levelStartDate = newStartDate
            trackingStore.updateForCurrentDate()
            
            alertMessage = "Days set to \(days)!\nNew start date: \(newStartDate.formatted(date: .abbreviated, time: .omitted))"
            showingAlert = true
        }
    }
    
    private func sendTestNotification() {
        guard !notificationTitle.isEmpty || !notificationBody.isEmpty else {
            alertMessage = "Please enter a title or body for the notification"
            showingAlert = true
            return
        }
        
        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            
            if settings.authorizationStatus == .notDetermined {
                do {
                    let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                    if !granted {
                        await MainActor.run {
                            alertMessage = "Notification permission denied. Please enable in Settings."
                            showingAlert = true
                        }
                        return
                    }
                } catch {
                    await MainActor.run {
                        alertMessage = "Failed to request permission: \(error.localizedDescription)"
                        showingAlert = true
                    }
                    return
                }
            } else if settings.authorizationStatus == .denied {
                await MainActor.run {
                    alertMessage = "Notifications are disabled. Please enable in Settings app."
                    showingAlert = true
                }
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = notificationTitle.isEmpty ? "Test Notification" : notificationTitle
            content.body = notificationBody.isEmpty ? "This is a test notification from Creator Panel" : notificationBody
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            let request = UNNotificationRequest(
                identifier: "creator_panel_test_\(UUID().uuidString)",
                content: content,
                trigger: trigger
            )
            
            do {
                try await center.add(request)
                await MainActor.run {
                    alertMessage = "Notification scheduled! It will appear in 3 seconds."
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Failed to schedule notification: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
}

#Preview {
    CreatorPanelView()
        .environment(UserProfileStore())
        .environment(TrackingStore())
}
#endif
