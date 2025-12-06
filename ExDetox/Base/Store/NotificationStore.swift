import Foundation

enum AppNotificationKind: Equatable, Hashable {
    case dailyCheckIn
    case challenge
    case levelUp(HealingLevel)
    case relapseSupport
    case custom
}

struct AppNotification: Identifiable, Equatable, Hashable {
    let id: UUID
    let title: String
    let message: String
    let kind: AppNotificationKind
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        message: String,
        kind: AppNotificationKind,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.kind = kind
        self.createdAt = createdAt
    }
}

@MainActor
@Observable
final class NotificationStore {
    var current: AppNotification?
    var queue: [AppNotification] = []
    
    func show(_ notification: AppNotification) {
        if current == nil {
            current = notification
        } else {
            queue.append(notification)
        }
    }
    
    func dismissCurrent() {
        if queue.isEmpty {
            current = nil
        } else {
            current = queue.removeFirst()
        }
    }
    
    func showDailyCheckIn() {
        let notification = AppNotification(
            title: "Quick vibe check",
            message: "Two taps to log today, then go back to your main character era.",
            kind: .dailyCheckIn
        )
        show(notification)
    }
    
    func showChallenge() {
        let notification = AppNotification(
            title: "New mini-mission",
            message: "Delete 5 photos or unfollow one account to speed up your healing.",
            kind: .challenge
        )
        show(notification)
    }
    
    func showLevelUp(for level: HealingLevel) {
        let notification = AppNotification(
            title: "New level unlocked: \(level.title)",
            message: "\(level.emoji) \(level.subtitle)",
            kind: .levelUp(level)
        )
        show(notification)
    }
    
    func showRelapseSupport() {
        let notification = AppNotification(
            title: "You slipped, not failed",
            message: "One text doesn’t erase your progress. Let’s get the streak back up.",
            kind: .relapseSupport
        )
        show(notification)
    }
}



