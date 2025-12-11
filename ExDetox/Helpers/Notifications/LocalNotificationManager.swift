import Foundation
import UserNotifications

enum NotificationType: String {
    case exQuiz = "ex_quiz"
    case streakCelebration = "streak_celebration"
}

struct ExQuizMessage: Codable, Identifiable {
    let id: String
    let text: String
    let exGenders: [String]
    let wrongAnswers: [String]
    let rightAnswer: String
    let decodedMeaning: String
}

struct ExQuizMessagesData: Codable {
    let messages: [ExQuizMessage]
}

struct StreakMilestone: Codable {
    let day: Int
    let emoji: String
    let title: String
    let message: String
    let notification: String
}

struct GenericStreakMessage: Codable {
    let emoji: String
    let title: String
    let message: String
    let notification: String
    
    func formatted(streak: Int) -> (emoji: String, title: String, message: String, notification: String) {
        return (
            emoji,
            title.replacingOccurrences(of: "{streak}", with: "\(streak)"),
            message.replacingOccurrences(of: "{streak}", with: "\(streak)"),
            notification.replacingOccurrences(of: "{streak}", with: "\(streak)")
        )
    }
}

struct StreakCelebrationsData: Codable {
    let milestones: [StreakMilestone]
    let generic: [GenericStreakMessage]
}

@MainActor
final class LocalNotificationManager: ObservableObject {
    static let shared = LocalNotificationManager()
    
    @Published private(set) var isAuthorized = false
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private var exQuizMessages: [ExQuizMessage] = []
    private var streakCelebrations: StreakCelebrationsData?
    
    private var usedMessageIds: Set<String> = []
    
    private init() {
        loadNotificationData()
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    private func loadNotificationData() {
        if let url = Bundle.main.url(forResource: "ExQuizMessages", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(ExQuizMessagesData.self, from: data) {
            exQuizMessages = decoded.messages
        }
        
        if let url = Bundle.main.url(forResource: "StreakCelebrations", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(StreakCelebrationsData.self, from: data) {
            streakCelebrations = decoded
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("❌ Notification authorization error: \(error)")
            return false
        }
    }
    
    func scheduleExQuizNotifications(exName: String, exGender: String) async {
        guard isAuthorized else { return }
        
        await cancelNotifications(ofType: .exQuiz)
        
        let calendar = Calendar.current
        let now = Date()
        
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else { return }
        
        let times = generateRandomTimes(count: 3, startHour: 18, endHour: 24)
        
        for (index, time) in times.enumerated() {
            guard let message = getRandomMessage(forGender: exGender) else { continue }
            
            var components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
            components.hour = time.hour
            components.minute = time.minute
            
            let content = UNMutableNotificationContent()
            content.title = exName.isEmpty ? "Ex" : exName
            content.body = message.text
            content.sound = .default
            content.userInfo = [
                "type": NotificationType.exQuiz.rawValue,
                "messageId": message.id
            ]
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(NotificationType.exQuiz.rawValue)_\(index)_\(UUID().uuidString)",
                content: content,
                trigger: trigger
            )
            
            do {
                try await UNUserNotificationCenter.current().add(request)
                usedMessageIds.insert(message.id)
            } catch {
                print("❌ Failed to schedule ex quiz notification: \(error)")
            }
        }
    }
    
    func scheduleStreakNotification(currentStreak: Int) async {
        guard isAuthorized else { return }
        
        await cancelNotifications(ofType: .streakCelebration)
        
        let calendar = Calendar.current
        let now = Date()
        
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else { return }
        
        var components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
        components.hour = 0
        components.minute = 0
        components.second = 5
        
        let nextStreak = currentStreak + 1
        let celebrationData = getCelebration(forDay: nextStreak)
        
        let content = UNMutableNotificationContent()
        content.title = celebrationData.title
        content.body = celebrationData.notification
        content.sound = .default
        content.userInfo = [
            "type": NotificationType.streakCelebration.rawValue,
            "streak": nextStreak
        ]
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(NotificationType.streakCelebration.rawValue)_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("❌ Failed to schedule streak notification: \(error)")
        }
    }
    
    func cancelNotifications(ofType type: NotificationType) async {
        let center = UNUserNotificationCenter.current()
        let pendingRequests = await center.pendingNotificationRequests()
        
        let identifiersToRemove = pendingRequests
            .filter { $0.identifier.hasPrefix(type.rawValue) }
            .map { $0.identifier }
        
        center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    private func generateRandomTimes(count: Int, startHour: Int, endHour: Int) -> [(hour: Int, minute: Int)] {
        var times: [(hour: Int, minute: Int)] = []
        let totalMinutes = (endHour - startHour) * 60
        let segmentSize = totalMinutes / count
        
        for i in 0..<count {
            let segmentStart = i * segmentSize
            let segmentEnd = (i + 1) * segmentSize
            let randomMinute = Int.random(in: segmentStart..<segmentEnd)
            
            let hour = startHour + (randomMinute / 60)
            let minute = randomMinute % 60
            times.append((hour: hour, minute: minute))
        }
        
        return times
    }
    
    private func getRandomMessage(forGender gender: String) -> ExQuizMessage? {
        let normalizedGender = gender.lowercased()
        let genderKey: String
        
        if normalizedGender.contains("male") && !normalizedGender.contains("female") {
            genderKey = "male"
        } else if normalizedGender.contains("female") {
            genderKey = "female"
        } else {
            genderKey = "other"
        }
        
        let filteredMessages = exQuizMessages.filter { message in
            message.exGenders.contains(genderKey) && !usedMessageIds.contains(message.id)
        }
        
        if filteredMessages.isEmpty {
            usedMessageIds.removeAll()
            return exQuizMessages.filter { $0.exGenders.contains(genderKey) }.randomElement()
        }
        
        return filteredMessages.randomElement()
    }
    
    func getMessage(byId id: String) -> ExQuizMessage? {
        return exQuizMessages.first { $0.id == id }
    }
    
    func getRandomMessage() -> ExQuizMessage? {
        return exQuizMessages.randomElement()
    }
    
    func getCelebration(forDay day: Int) -> (emoji: String, title: String, message: String, notification: String) {
        if let milestone = streakCelebrations?.milestones.first(where: { $0.day == day }) {
            return (milestone.emoji, milestone.title, milestone.message, milestone.notification)
        }
        
        if let generic = streakCelebrations?.generic.randomElement() {
            return generic.formatted(streak: day)
        }
        
        return ("🔥", "Day \(day)!", "Keep going strong!", "Day \(day)! 🔥 Keep that energy")
    }
    
    #if DEBUG
    func triggerTestExQuizNotification(exName: String) async {
        guard let message = exQuizMessages.randomElement() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = exName.isEmpty ? "Ex" : exName
        content.body = message.text
        content.sound = .default
        content.userInfo = [
            "type": NotificationType.exQuiz.rawValue,
            "messageId": message.id
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test_\(NotificationType.exQuiz.rawValue)_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("❌ Failed to schedule test notification: \(error)")
        }
    }
    
    func triggerTestStreakNotification(streak: Int) async {
        let celebrationData = getCelebration(forDay: streak)
        
        let content = UNMutableNotificationContent()
        content.title = celebrationData.title
        content.body = celebrationData.notification
        content.sound = .default
        content.userInfo = [
            "type": NotificationType.streakCelebration.rawValue,
            "streak": streak
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test_\(NotificationType.streakCelebration.rawValue)_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("❌ Failed to schedule test notification: \(error)")
        }
    }
    #endif
}
