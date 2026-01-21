import Foundation
import WidgetKit

struct WidgetData: Codable {
    var currentStreakDays: Int
    var exName: String
    var currentLevel: String
    var levelEmoji: String
    var levelColor: String
    var maxStreak: Int
    var lastUpdated: Date
    
    // Widget customization
    var backgroundColor: String
    var accentColor: String
    var showExName: Bool
    
    static var empty: WidgetData {
        WidgetData(
            currentStreakDays: 0,
            exName: "",
            currentLevel: "Emergency Mode",
            levelEmoji: "💔",
            levelColor: "FF6B6B",
            maxStreak: 0,
            lastUpdated: Date(),
            backgroundColor: "FFFFFF",
            accentColor: "000000",
            showExName: false
        )
    }
}

struct WidgetSettings: Codable, Equatable {
    var backgroundColor: String
    var accentColor: String
    var showExName: Bool
    
    static var defaults: WidgetSettings {
        WidgetSettings(
            backgroundColor: "FFFFFF",
            accentColor: "000000",
            showExName: false
        )
    }
}

@MainActor
final class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let appGroupIdentifier = "group.com.app.exdetox"
    private let widgetDataKey = "widgetData"
    private let widgetSettingsKey = "widgetSettings"
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }
    
    private init() {}
    
    // MARK: - Widget Data
    
    func updateWidgetData(
        streakDays: Int,
        exName: String,
        level: String,
        levelEmoji: String,
        levelColor: String,
        maxStreak: Int
    ) {
        let settings = getWidgetSettings()
        
        let data = WidgetData(
            currentStreakDays: streakDays,
            exName: exName,
            currentLevel: level,
            levelEmoji: levelEmoji,
            levelColor: levelColor,
            maxStreak: maxStreak,
            lastUpdated: Date(),
            backgroundColor: settings.backgroundColor,
            accentColor: settings.accentColor,
            showExName: settings.showExName
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            sharedDefaults?.set(encoded, forKey: widgetDataKey)
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func getWidgetData() -> WidgetData {
        guard let data = sharedDefaults?.data(forKey: widgetDataKey),
              let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return .empty
        }
        return decoded
    }
    
    // MARK: - Widget Settings
    
    func updateWidgetSettings(_ settings: WidgetSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            sharedDefaults?.set(encoded, forKey: widgetSettingsKey)
        }
        
        // Also update the widget data with new settings
        var currentData = getWidgetData()
        currentData.backgroundColor = settings.backgroundColor
        currentData.accentColor = settings.accentColor
        currentData.showExName = settings.showExName
        
        if let encoded = try? JSONEncoder().encode(currentData) {
            sharedDefaults?.set(encoded, forKey: widgetDataKey)
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func getWidgetSettings() -> WidgetSettings {
        guard let data = sharedDefaults?.data(forKey: widgetSettingsKey),
              let decoded = try? JSONDecoder().decode(WidgetSettings.self, from: data) else {
            return .defaults
        }
        return decoded
    }
}
