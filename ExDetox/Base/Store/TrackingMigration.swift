import Foundation
import SwiftData

enum TrackingMigration {
    static let currentVersion = 1
    
    @MainActor
    static func migrateIfNeeded(context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<TrackingRecord>()
            guard let record = try context.fetch(descriptor).first else {
                return
            }
            
            let recordVersion = record.schemaVersion
            
            if recordVersion < currentVersion {
                print("[TrackingMigration] Migrating from version \(recordVersion) to \(currentVersion)")
                performMigration(record: record, fromVersion: recordVersion, context: context)
            }
        } catch {
            print("[TrackingMigration] Migration check failed: \(error.localizedDescription)")
        }
    }
    
    private static func performMigration(record: TrackingRecord, fromVersion: Int, context: ModelContext) {
        var version = fromVersion
        
        while version < currentVersion {
            switch version {
            case 0:
                migrateV0ToV1(record: record)
            default:
                break
            }
            version += 1
        }
        
        record.schemaVersion = currentVersion
        
        do {
            try context.save()
            print("[TrackingMigration] Migration to version \(currentVersion) completed successfully")
        } catch {
            print("[TrackingMigration] Failed to save migration: \(error.localizedDescription)")
        }
    }
    
    private static func migrateV0ToV1(record: TrackingRecord) {
        if record.currentLevelRaw.isEmpty {
            record.currentLevelRaw = HealingLevel.emergency.rawValue
        }
        
        if let intValue = Int(record.currentLevelRaw) {
            let level: HealingLevel
            switch intValue {
            case 0: level = .emergency
            case 1: level = .withdrawal
            case 2: level = .reality
            case 3: level = .glowUp
            case 4: level = .unbothered
            default: level = .emergency
            }
            record.currentLevelRaw = level.rawValue
        }
        
        if record.bonusDays < 0 {
            record.bonusDays = 0
        }
        if record.lifetimeBonusDays < 0 {
            record.lifetimeBonusDays = 0
        }
        if record.relapseCount < 0 {
            record.relapseCount = 0
        }
        if record.maxStreak < 0 {
            record.maxStreak = 0
        }
    }
}
