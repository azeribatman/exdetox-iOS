import Foundation
import SwiftData

@MainActor
enum TrackingPersistence {
    static func bootstrap(store: TrackingStore, context: ModelContext) {
        let descriptor = FetchDescriptor<TrackingRecord>()
        if let existing = try? context.fetch(descriptor).first {
            store.state = TrackingState(
                exName: existing.exName,
                programStartDate: existing.programStartDate,
                totalProgramDays: existing.totalProgramDays,
                levelStartDate: existing.levelStartDate,
                currentLevel: HealingLevel(rawValue: existing.currentLevelRaw) ?? .emergency,
                noContactStartDate: existing.noContactStartDate,
                lastRelapseDate: existing.lastRelapseDate,
                relapseCount: existing.relapseCount,
                maxStreak: existing.maxStreak,
                bonusDays: existing.bonusDays,
                relapseDates: existing.relapses.map { $0.date },
                powerActions: existing.powerActions.map { PowerActionRecord(id: $0.id, type: $0.type, date: $0.date, note: $0.note) },
                dailyCheckIns: existing.dailyCheckIns.map { DailyCheckIn(id: $0.id, date: $0.date, mood: $0.mood, urge: $0.urge, note: $0.note) },
                badges: existing.badges.map { Badge(id: $0.id, type: $0.type, earnedDate: $0.earnedDate) }
            )
            store.updateForCurrentDate()
        } else {
            let state = store.state
            let record = TrackingRecord(
                exName: state.exName,
                programStartDate: state.programStartDate,
                totalProgramDays: state.totalProgramDays,
                levelStartDate: state.levelStartDate,
                currentLevelRaw: state.currentLevel.rawValue,
                noContactStartDate: state.noContactStartDate,
                lastRelapseDate: state.lastRelapseDate,
                relapseCount: state.relapseCount,
                maxStreak: state.maxStreak,
                bonusDays: state.bonusDays
            )
            context.insert(record)
            try? context.save()
        }
    }
    
    static func save(store: TrackingStore, context: ModelContext) {
        let descriptor = FetchDescriptor<TrackingRecord>()
        let record: TrackingRecord
        if let existing = try? context.fetch(descriptor).first {
            record = existing
        } else {
            let state = store.state
            record = TrackingRecord(
                exName: state.exName,
                programStartDate: state.programStartDate,
                totalProgramDays: state.totalProgramDays,
                levelStartDate: state.levelStartDate,
                currentLevelRaw: state.currentLevel.rawValue,
                noContactStartDate: state.noContactStartDate,
                lastRelapseDate: state.lastRelapseDate,
                relapseCount: state.relapseCount,
                maxStreak: state.maxStreak,
                bonusDays: state.bonusDays
            )
            context.insert(record)
        }
        
        let state = store.state
        record.exName = state.exName
        record.programStartDate = state.programStartDate
        record.totalProgramDays = state.totalProgramDays
        record.levelStartDate = state.levelStartDate
        record.currentLevelRaw = state.currentLevel.rawValue
        record.noContactStartDate = state.noContactStartDate
        record.lastRelapseDate = state.lastRelapseDate
        record.relapseCount = state.relapseCount
        record.maxStreak = state.maxStreak
        record.bonusDays = state.bonusDays
        
        try? context.save()
    }
    
    static func recordRelapse(store: TrackingStore, context: ModelContext, date: Date = Date()) {
        store.recordRelapse(on: date)
        
        let descriptor = FetchDescriptor<TrackingRecord>()
        guard let record = try? context.fetch(descriptor).first else { return }
        
        let relapse = RelapseRecord(date: date)
        record.relapses.append(relapse)
        record.lastRelapseDate = store.state.lastRelapseDate
        record.relapseCount = store.state.relapseCount
        record.maxStreak = store.state.maxStreak
        record.noContactStartDate = store.state.noContactStartDate
        record.levelStartDate = store.state.levelStartDate
        record.bonusDays = store.state.bonusDays
        
        try? context.save()
    }
    
    static func recordPowerAction(store: TrackingStore, context: ModelContext, type: PowerActionType, date: Date = Date(), note: String? = nil) {
        store.recordPowerAction(type, on: date, note: note)
        
        let descriptor = FetchDescriptor<TrackingRecord>()
        guard let record = try? context.fetch(descriptor).first else { return }
        
        let actionObject = PowerActionObject(type: type, date: date, note: note)
        record.powerActions.append(actionObject)
        record.levelStartDate = store.state.levelStartDate
        record.bonusDays = store.state.bonusDays
        record.currentLevelRaw = store.state.currentLevel.rawValue
        
        syncBadges(store: store, record: record)
        
        try? context.save()
    }
    
    static func recordDailyCheckIn(store: TrackingStore, context: ModelContext, mood: Int, urge: Int, note: String? = nil, date: Date = Date()) {
        store.recordDailyCheckIn(mood: mood, urge: urge, note: note, on: date)
        
        let descriptor = FetchDescriptor<TrackingRecord>()
        guard let record = try? context.fetch(descriptor).first else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        
        if let existingIndex = record.dailyCheckIns.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            record.dailyCheckIns[existingIndex].mood = mood
            record.dailyCheckIns[existingIndex].urge = urge
            record.dailyCheckIns[existingIndex].note = note
        } else {
            let checkInRecord = DailyCheckInRecord(date: today, mood: mood, urge: urge, note: note)
            record.dailyCheckIns.append(checkInRecord)
        }
        
        try? context.save()
    }
    
    static func awardBadge(store: TrackingStore, context: ModelContext, type: BadgeType) {
        store.awardBadge(type)
        
        let descriptor = FetchDescriptor<TrackingRecord>()
        guard let record = try? context.fetch(descriptor).first else { return }
        
        if !record.badges.contains(where: { $0.type == type }) {
            let badgeRecord = BadgeRecord(type: type)
            record.badges.append(badgeRecord)
            try? context.save()
        }
    }
    
    private static func syncBadges(store: TrackingStore, record: TrackingRecord) {
        let existingTypes = Set(record.badges.map(\.type))
        
        for badge in store.state.badges {
            if !existingTypes.contains(badge.type) {
                let badgeRecord = BadgeRecord(type: badge.type, earnedDate: badge.earnedDate)
                record.badges.append(badgeRecord)
            }
        }
    }
}
