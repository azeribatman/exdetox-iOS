import Foundation
import SwiftData

@Model
final class TrackingRecord {
    @Attribute(.unique) var id: UUID
    var exName: String
    var programStartDate: Date
    var totalProgramDays: Int
    var levelStartDate: Date
    var currentLevelRaw: Int
    var noContactStartDate: Date
    var lastRelapseDate: Date?
    var relapseCount: Int
    var maxStreak: Int
    var bonusDays: Double
    @Relationship(deleteRule: .cascade) var relapses: [RelapseRecord]
    @Relationship(deleteRule: .cascade) var powerActions: [PowerActionObject]
    @Relationship(deleteRule: .cascade) var dailyCheckIns: [DailyCheckInRecord]
    @Relationship(deleteRule: .cascade) var badges: [BadgeRecord]
    
    init(
        id: UUID = UUID(),
        exName: String,
        programStartDate: Date,
        totalProgramDays: Int,
        levelStartDate: Date,
        currentLevelRaw: Int,
        noContactStartDate: Date,
        lastRelapseDate: Date?,
        relapseCount: Int,
        maxStreak: Int,
        bonusDays: Double,
        relapses: [RelapseRecord] = [],
        powerActions: [PowerActionObject] = [],
        dailyCheckIns: [DailyCheckInRecord] = [],
        badges: [BadgeRecord] = []
    ) {
        self.id = id
        self.exName = exName
        self.programStartDate = programStartDate
        self.totalProgramDays = totalProgramDays
        self.levelStartDate = levelStartDate
        self.currentLevelRaw = currentLevelRaw
        self.noContactStartDate = noContactStartDate
        self.lastRelapseDate = lastRelapseDate
        self.relapseCount = relapseCount
        self.maxStreak = maxStreak
        self.bonusDays = bonusDays
        self.relapses = relapses
        self.powerActions = powerActions
        self.dailyCheckIns = dailyCheckIns
        self.badges = badges
    }
}

@Model
final class RelapseRecord {
    @Attribute(.unique) var id: UUID
    var date: Date
    
    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
    }
}

@Model
final class PowerActionObject {
    @Attribute(.unique) var id: UUID
    var typeRaw: String
    var date: Date
    var note: String?
    
    init(id: UUID = UUID(), type: PowerActionType, date: Date = Date(), note: String? = nil) {
        self.id = id
        self.typeRaw = type.rawValue
        self.date = date
        self.note = note
    }
    
    var type: PowerActionType {
        PowerActionType(rawValue: typeRaw) ?? .custom
    }
}

@Model
final class DailyCheckInRecord {
    @Attribute(.unique) var id: UUID
    var date: Date
    var mood: Int
    var urge: Int
    var note: String?
    
    init(id: UUID = UUID(), date: Date = Date(), mood: Int = 3, urge: Int = 5, note: String? = nil) {
        self.id = id
        self.date = date
        self.mood = mood
        self.urge = urge
        self.note = note
    }
}

@Model
final class BadgeRecord {
    @Attribute(.unique) var id: UUID
    var typeRaw: String
    var earnedDate: Date
    
    init(id: UUID = UUID(), type: BadgeType, earnedDate: Date = Date()) {
        self.id = id
        self.typeRaw = type.rawValue
        self.earnedDate = earnedDate
    }
    
    var type: BadgeType {
        BadgeType(rawValue: typeRaw) ?? .firstDay
    }
}

@Model
final class WhyItemRecord {
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date
    var imageFileName: String?
    
    init(id: UUID = UUID(), title: String, createdAt: Date = Date(), imageFileName: String? = nil) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.imageFileName = imageFileName
    }
}
