import Foundation
import SwiftData

enum PersistenceError: Error, LocalizedError {
    case saveFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    case dataIntegrityError(String)
    case migrationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch: \(error.localizedDescription)"
        case .dataIntegrityError(let message):
            return "Data integrity error: \(message)"
        case .migrationFailed(let message):
            return "Migration failed: \(message)"
        }
    }
}

@MainActor
enum TrackingPersistence {
    
    private static func normalizedDate(_ date: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
        return calendar.startOfDay(for: date)
    }
    
    private static func enforceSingleRecord(context: ModelContext) throws {
        let descriptor = FetchDescriptor<TrackingRecord>(sortBy: [SortDescriptor(\.programStartDate, order: .forward)])
        let records = try context.fetch(descriptor)
        
        if records.count > 1 {
            print("[TrackingPersistence] Warning: Found \(records.count) records, keeping only the first one")
            for record in records.dropFirst() {
                context.delete(record)
            }
            try context.save()
        }
    }
    
    private static func cleanupOrphanedRelationships(record: TrackingRecord, context: ModelContext) {
        let uniqueRelapseIds = Set(record.relapses.map(\.id))
        if uniqueRelapseIds.count != record.relapses.count {
            var seen = Set<UUID>()
            record.relapses.removeAll { relapse in
                if seen.contains(relapse.id) {
                    return true
                }
                seen.insert(relapse.id)
                return false
            }
        }
        
        let uniquePowerActionIds = Set(record.powerActions.map(\.id))
        if uniquePowerActionIds.count != record.powerActions.count {
            var seen = Set<UUID>()
            record.powerActions.removeAll { action in
                if seen.contains(action.id) {
                    return true
                }
                seen.insert(action.id)
                return false
            }
        }
        
        let uniqueCheckInIds = Set(record.dailyCheckIns.map(\.id))
        if uniqueCheckInIds.count != record.dailyCheckIns.count {
            var seen = Set<UUID>()
            record.dailyCheckIns.removeAll { checkIn in
                if seen.contains(checkIn.id) {
                    return true
                }
                seen.insert(checkIn.id)
                return false
            }
        }
        
        let uniqueBadgeTypes = Set(record.badges.map(\.typeRaw))
        if uniqueBadgeTypes.count != record.badges.count {
            var seen = Set<String>()
            record.badges.removeAll { badge in
                if seen.contains(badge.typeRaw) {
                    return true
                }
                seen.insert(badge.typeRaw)
                return false
            }
        }
    }
    
    private static func validateDataIntegrity(record: TrackingRecord) {
        if record.relapseCount < 0 {
            record.relapseCount = 0
        }
        if record.maxStreak < 0 {
            record.maxStreak = 0
        }
        if record.bonusDays < 0 {
            record.bonusDays = 0
        }
        if record.lifetimeBonusDays < 0 {
            record.lifetimeBonusDays = 0
        }
        if record.totalProgramDays < 1 {
            record.totalProgramDays = 180
        }
        
        if record.noContactStartDate > Date() {
            record.noContactStartDate = Date()
        }
        if record.levelStartDate > Date() {
            record.levelStartDate = Date()
        }
        if record.programStartDate > Date() {
            record.programStartDate = Date()
        }
        
        if HealingLevel(rawValue: record.currentLevelRaw) == nil {
            record.currentLevelRaw = HealingLevel.emergency.rawValue
        }
    }
    
    static func bootstrap(store: TrackingStore, context: ModelContext, isNewUser: Bool = false) {
        do {
            try enforceSingleRecord(context: context)
            
            let descriptor = FetchDescriptor<TrackingRecord>()
            let records = try context.fetch(descriptor)
            
            if let existing = records.first {
                cleanupOrphanedRelationships(record: existing, context: context)
                validateDataIntegrity(record: existing)
                
                store.state = TrackingState(
                    exName: existing.exName,
                    programStartDate: existing.programStartDate,
                    totalProgramDays: existing.totalProgramDays,
                    levelStartDate: existing.levelStartDate,
                    currentLevel: existing.currentLevel,
                    noContactStartDate: existing.noContactStartDate,
                    lastRelapseDate: existing.lastRelapseDate,
                    relapseCount: existing.relapseCount,
                    maxStreak: existing.maxStreak,
                    bonusDays: existing.bonusDays,
                    lifetimeBonusDays: existing.lifetimeBonusDays,
                    relapseDates: existing.relapses.map { $0.date },
                    powerActions: existing.powerActions.map { PowerActionRecord(id: $0.id, type: $0.type, date: $0.date, note: $0.note) },
                    dailyCheckIns: existing.dailyCheckIns.map { DailyCheckIn(id: $0.id, date: $0.date, mood: $0.mood, urge: $0.urge, note: $0.note) },
                    badges: existing.badges.map { Badge(id: $0.id, type: $0.type, earnedDate: $0.earnedDate) }
                )
                store.updateForCurrentDate()
                
                try context.save()
            } else {
                let now = Date()
                
                if isNewUser {
                    store.state.programStartDate = now
                    store.state.levelStartDate = now
                    store.state.noContactStartDate = now
                }
                
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
                    bonusDays: state.bonusDays,
                    lifetimeBonusDays: state.lifetimeBonusDays
                )
                context.insert(record)
                try context.save()
            }
        } catch {
            print("[TrackingPersistence] Bootstrap error: \(error.localizedDescription)")
        }
    }
    
    static func save(store: TrackingStore, context: ModelContext) {
        do {
            try enforceSingleRecord(context: context)
            
            let descriptor = FetchDescriptor<TrackingRecord>()
            let records = try context.fetch(descriptor)
            
            let record: TrackingRecord
            if let existing = records.first {
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
                    bonusDays: state.bonusDays,
                    lifetimeBonusDays: state.lifetimeBonusDays
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
            record.lifetimeBonusDays = state.lifetimeBonusDays
            
            validateDataIntegrity(record: record)
            
            try context.save()
        } catch {
            print("[TrackingPersistence] Save error: \(error.localizedDescription)")
        }
    }
    
    static func recordRelapse(store: TrackingStore, context: ModelContext, date: Date = Date()) {
        store.recordRelapse(on: date)
        
        do {
            let descriptor = FetchDescriptor<TrackingRecord>()
            guard let record = try context.fetch(descriptor).first else {
                print("[TrackingPersistence] No record found for relapse")
                return
            }
            
            let normalizedDate = normalizedDate(date)
            let relapse = RelapseRecord(date: normalizedDate)
            record.relapses.append(relapse)
            record.lastRelapseDate = store.state.lastRelapseDate
            record.relapseCount = store.state.relapseCount
            record.maxStreak = store.state.maxStreak
            record.noContactStartDate = store.state.noContactStartDate
            record.levelStartDate = store.state.levelStartDate
            record.bonusDays = store.state.bonusDays
            record.currentLevelRaw = store.state.currentLevel.rawValue
            
            try context.save()
        } catch {
            print("[TrackingPersistence] Record relapse error: \(error.localizedDescription)")
        }
    }
    
    static func recordPowerAction(store: TrackingStore, context: ModelContext, type: PowerActionType, date: Date = Date(), note: String? = nil) {
        store.recordPowerAction(type, on: date, note: note)
        
        do {
            let descriptor = FetchDescriptor<TrackingRecord>()
            guard let record = try context.fetch(descriptor).first else {
                print("[TrackingPersistence] No record found for power action")
                return
            }
            
            if record.powerActions.contains(where: { $0.typeRaw == type.rawValue }) {
                return
            }
            
            let actionObject = PowerActionObject(type: type, date: date, note: note)
            record.powerActions.append(actionObject)
            record.levelStartDate = store.state.levelStartDate
            record.bonusDays = store.state.bonusDays
            record.lifetimeBonusDays = store.state.lifetimeBonusDays
            record.currentLevelRaw = store.state.currentLevel.rawValue
            
            syncBadges(store: store, record: record)
            
            try context.save()
        } catch {
            print("[TrackingPersistence] Record power action error: \(error.localizedDescription)")
        }
    }
    
    static func recordDailyCheckIn(store: TrackingStore, context: ModelContext, mood: Int, urge: Int, note: String? = nil, date: Date = Date()) {
        let validatedMood = min(max(mood, 1), 5)
        let validatedUrge = min(max(urge, 0), 10)
        
        store.recordDailyCheckIn(mood: validatedMood, urge: validatedUrge, note: note, on: date)
        
        do {
            let descriptor = FetchDescriptor<TrackingRecord>()
            guard let record = try context.fetch(descriptor).first else {
                print("[TrackingPersistence] No record found for daily check-in")
                return
            }
            
            let today = normalizedDate(date)
            
            if let existingIndex = record.dailyCheckIns.firstIndex(where: { 
                Calendar.current.isDate($0.date, inSameDayAs: today) 
            }) {
                record.dailyCheckIns[existingIndex].mood = validatedMood
                record.dailyCheckIns[existingIndex].urge = validatedUrge
                record.dailyCheckIns[existingIndex].note = note
            } else {
                let checkInRecord = DailyCheckInRecord(date: today, mood: validatedMood, urge: validatedUrge, note: note)
                record.dailyCheckIns.append(checkInRecord)
            }
            
            try context.save()
        } catch {
            print("[TrackingPersistence] Record daily check-in error: \(error.localizedDescription)")
        }
    }
    
    static func awardBadge(store: TrackingStore, context: ModelContext, type: BadgeType) {
        store.awardBadge(type)
        
        do {
            let descriptor = FetchDescriptor<TrackingRecord>()
            guard let record = try context.fetch(descriptor).first else {
                print("[TrackingPersistence] No record found for badge award")
                return
            }
            
            if !record.badges.contains(where: { $0.type == type }) {
                let badgeRecord = BadgeRecord(type: type)
                record.badges.append(badgeRecord)
                try context.save()
            }
        } catch {
            print("[TrackingPersistence] Award badge error: \(error.localizedDescription)")
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
    
    static func resetProgress(store: TrackingStore, context: ModelContext) {
        store.resetProgress()
        
        do {
            let descriptor = FetchDescriptor<TrackingRecord>()
            guard let record = try context.fetch(descriptor).first else {
                print("[TrackingPersistence] No record found for reset")
                return
            }
            
            let relapse = RelapseRecord(date: normalizedDate(Date()))
            record.relapses.append(relapse)
            record.noContactStartDate = store.state.noContactStartDate
            record.levelStartDate = store.state.levelStartDate
            record.currentLevelRaw = store.state.currentLevel.rawValue
            record.bonusDays = store.state.bonusDays
            record.relapseCount = store.state.relapseCount
            record.lastRelapseDate = store.state.lastRelapseDate
            record.maxStreak = store.state.maxStreak
            
            try context.save()
        } catch {
            print("[TrackingPersistence] Reset progress error: \(error.localizedDescription)")
        }
    }
    
    static func runIntegrityCheck(context: ModelContext) {
        do {
            TrackingMigration.migrateIfNeeded(context: context)
            
            try enforceSingleRecord(context: context)
            
            let descriptor = FetchDescriptor<TrackingRecord>()
            guard let record = try context.fetch(descriptor).first else { return }
            
            cleanupOrphanedRelationships(record: record, context: context)
            validateDataIntegrity(record: record)
            
            try context.save()
            print("[TrackingPersistence] Integrity check completed successfully")
        } catch {
            print("[TrackingPersistence] Integrity check error: \(error.localizedDescription)")
        }
    }
}
