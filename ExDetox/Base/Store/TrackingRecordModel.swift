import Foundation
import SwiftData

@Model
final class TrackingRecord {
    static let currentSchemaVersion: Int = 1
    
    @Attribute(.unique) var id: UUID = UUID()
    var schemaVersion: Int = TrackingRecord.currentSchemaVersion
    var exName: String = ""
    var programStartDate: Date = Date()
    var totalProgramDays: Int = 180
    var levelStartDate: Date = Date()
    var currentLevelRaw: String = HealingLevel.emergency.rawValue
    var noContactStartDate: Date = Date()
    var lastRelapseDate: Date?
    var relapseCount: Int = 0
    var maxStreak: Int = 0
    var bonusDays: Double = 0 {
        didSet {
            bonusDays = max(0, min(bonusDays, Double(HealingLevel.emergency.maxBonusDays)))
        }
    }
    var lifetimeBonusDays: Double = 0 {
        didSet {
            lifetimeBonusDays = max(0, lifetimeBonusDays)
        }
    }
    @Relationship(deleteRule: .cascade) var relapses: [RelapseRecord] = []
    @Relationship(deleteRule: .cascade) var powerActions: [PowerActionObject] = []
    @Relationship(deleteRule: .cascade) var dailyCheckIns: [DailyCheckInRecord] = []
    @Relationship(deleteRule: .cascade) var badges: [BadgeRecord] = []
    
    init(
        id: UUID = UUID(),
        schemaVersion: Int = TrackingRecord.currentSchemaVersion,
        exName: String,
        programStartDate: Date,
        totalProgramDays: Int,
        levelStartDate: Date,
        currentLevelRaw: String,
        noContactStartDate: Date,
        lastRelapseDate: Date?,
        relapseCount: Int,
        maxStreak: Int,
        bonusDays: Double,
        lifetimeBonusDays: Double = 0,
        relapses: [RelapseRecord] = [],
        powerActions: [PowerActionObject] = [],
        dailyCheckIns: [DailyCheckInRecord] = [],
        badges: [BadgeRecord] = []
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.exName = exName
        self.programStartDate = programStartDate
        self.totalProgramDays = max(1, totalProgramDays)
        self.levelStartDate = levelStartDate
        self.currentLevelRaw = currentLevelRaw
        self.noContactStartDate = noContactStartDate
        self.lastRelapseDate = lastRelapseDate
        self.relapseCount = max(0, relapseCount)
        self.maxStreak = max(0, maxStreak)
        self.bonusDays = max(0, min(bonusDays, Double(HealingLevel.emergency.maxBonusDays)))
        self.lifetimeBonusDays = max(0, lifetimeBonusDays)
        self.relapses = relapses
        self.powerActions = powerActions
        self.dailyCheckIns = dailyCheckIns
        self.badges = badges
    }
    
    var currentLevel: HealingLevel {
        HealingLevel(rawValue: currentLevelRaw) ?? .emergency
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
        PowerActionType(rawValue: typeRaw) ?? .deletePhotos
    }
}

@Model
final class DailyCheckInRecord {
    @Attribute(.unique) var id: UUID
    var date: Date
    var mood: Int {
        didSet {
            mood = min(max(mood, 1), 5)
        }
    }
    var urge: Int {
        didSet {
            urge = min(max(urge, 0), 10)
        }
    }
    var note: String?
    
    init(id: UUID = UUID(), date: Date = Date(), mood: Int = 3, urge: Int = 5, note: String? = nil) {
        self.id = id
        self.date = date
        self.mood = min(max(mood, 1), 5)
        self.urge = min(max(urge, 0), 10)
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
