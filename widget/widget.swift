//
//  widget.swift
//  widget
//
//  Created by Aykhan Safarli on 21.01.26.
//

import WidgetKit
import SwiftUI

// MARK: - Shared Data Access

struct WidgetDataProvider {
    private let appGroupIdentifier = "group.com.app.exdetox"
    private let widgetDataKey = "widgetData"
    
    func getWidgetData() -> WidgetData {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = sharedDefaults.data(forKey: widgetDataKey),
              let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return .empty
        }
        return decoded
    }
}

struct WidgetData: Codable {
    var currentStreakDays: Int
    var exName: String
    var currentLevel: String
    var levelEmoji: String
    var levelColor: String
    var maxStreak: Int
    var lastUpdated: Date
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

// MARK: - Timeline

struct ExDetoxEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

struct ExDetoxTimelineProvider: TimelineProvider {
    private let dataProvider = WidgetDataProvider()
    
    func placeholder(in context: Context) -> ExDetoxEntry {
        ExDetoxEntry(date: Date(), data: .empty)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ExDetoxEntry) -> Void) {
        completion(ExDetoxEntry(date: Date(), data: dataProvider.getWidgetData()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ExDetoxEntry>) -> Void) {
        let entry = ExDetoxEntry(date: Date(), data: dataProvider.getWidgetData())
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - HOME SCREEN WIDGET

struct ExDetoxHomeWidget: Widget {
    let kind = "ExDetoxHomeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ExDetoxTimelineProvider()) { entry in
            HomeWidgetView(entry: entry)
        }
        .configurationDisplayName("ExDetox")
        .description("Track your healing journey.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct HomeWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: ExDetoxEntry
    
    private var bgColor: Color {
        Color(hex: entry.data.backgroundColor)
    }
    
    private var textColor: Color {
        Color(hex: entry.data.accentColor)
    }
    
    private var isDark: Bool {
        entry.data.backgroundColor.uppercased() == "000000" || 
        entry.data.backgroundColor.uppercased() == "1C1C1E" ||
        entry.data.backgroundColor.uppercased() == "2C2C2E"
    }
    
    var body: some View {
        ZStack {
            bgColor
            
            switch family {
            case .systemSmall:
                smallWidget
            case .systemMedium:
                mediumWidget
            case .systemLarge:
                largeWidget
            default:
                smallWidget
            }
        }
        .containerBackground(for: .widget) {
            bgColor
        }
    }
    
    // MARK: - Small Widget
    private var smallWidget: some View {
        VStack(spacing: 0) {
            // Header - centered
            Text("ExDetox")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(textColor.opacity(0.4))
            
            Spacer()
            
            // Number - elegant serif
            Text("\(entry.data.currentStreakDays)")
                .font(.system(size: 44, weight: .regular, design: .serif))
                .foregroundStyle(textColor)
                .minimumScaleFactor(0.5)
            
            Text("days")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(textColor.opacity(0.4))
                .textCase(.uppercase)
                .tracking(2)
            
            Spacer()
            
            // Motto
            Text("Be Proud")
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(textColor.opacity(0.3))
                .italic()
        }
        .padding(14)
    }
    
    // MARK: - Medium Widget
    private var mediumWidget: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("ExDetox")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(textColor.opacity(0.4))
                Spacer()
                Text("Be Proud")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(textColor.opacity(0.3))
                    .italic()
            }
            
            Spacer()
            
            HStack(spacing: 0) {
                // Left side - Number
                VStack(spacing: 2) {
                    Text("\(entry.data.currentStreakDays)")
                        .font(.system(size: 52, weight: .regular, design: .serif))
                        .foregroundStyle(textColor)
                        .minimumScaleFactor(0.5)
                    Text("days")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(textColor.opacity(0.4))
                        .textCase(.uppercase)
                        .tracking(2)
                }
                .frame(maxWidth: .infinity)
                
                // Divider
                Rectangle()
                    .fill(textColor.opacity(0.1))
                    .frame(width: 1)
                    .padding(.vertical, 12)
                
                // Right side - Stats
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("best")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(textColor.opacity(0.4))
                        Text("\(entry.data.maxStreak)")
                            .font(.system(size: 22, weight: .regular, design: .serif))
                            .foregroundStyle(textColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("status")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(textColor.opacity(0.4))
                        Text("Healing")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(textColor.opacity(0.7))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
            }
            
            Spacer()
        }
        .padding(16)
    }
    
    // MARK: - Large Widget
    private var largeWidget: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("ExDetox")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(textColor.opacity(0.4))
                Spacer()
                Text("Be Proud")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(textColor.opacity(0.3))
                    .italic()
            }
            
            Spacer()
            
            // Main number - elegant serif
            Text("\(entry.data.currentStreakDays)")
                .font(.system(size: 88, weight: .regular, design: .serif))
                .foregroundStyle(textColor)
                .minimumScaleFactor(0.5)
            
            Text("days free")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(textColor.opacity(0.4))
                .textCase(.uppercase)
                .tracking(4)
            
            Spacer()
            
            // Bottom stats
            HStack(spacing: 0) {
                statItem(label: "best", value: "\(entry.data.maxStreak)")
                
                Rectangle()
                    .fill(textColor.opacity(0.08))
                    .frame(width: 1, height: 36)
                
                statItem(label: "status", value: "Healing")
                
                Rectangle()
                    .fill(textColor.opacity(0.08))
                    .frame(width: 1, height: 36)
                
                statItem(label: "streak", value: entry.data.currentStreakDays > entry.data.maxStreak ? "New" : "Going")
            }
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(textColor.opacity(0.04))
            )
        }
        .padding(20)
    }
    
    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(textColor.opacity(0.4))
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(textColor.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - LOCK SCREEN WIDGET

struct ExDetoxLockScreenWidget: Widget {
    let kind = "ExDetoxLockScreenWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ExDetoxTimelineProvider()) { entry in
            LockScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("ExDetox")
        .description("Your streak on lock screen.")
        .supportedFamilies([.accessoryRectangular, .accessoryInline])
    }
}

struct LockScreenWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: ExDetoxEntry
    
    var body: some View {
        switch family {
        case .accessoryRectangular:
            rectangularWidget
        case .accessoryInline:
            inlineWidget
        default:
            inlineWidget
        }
    }
    
    // MARK: - Rectangular Lock Screen
    private var rectangularWidget: some View {
        HStack(spacing: 0) {
            // Days number - elegant serif style
            VStack(spacing: -2) {
                Text("\(entry.data.currentStreakDays)")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                Text("days")
                    .font(.system(size: 7, weight: .medium, design: .rounded))
                    .opacity(0.5)
                    .textCase(.uppercase)
                    .tracking(1)
            }
            .frame(width: 50)
            
            // Divider
            Rectangle()
                .fill(.white.opacity(0.2))
                .frame(width: 1)
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
            
            // Right side
            VStack(alignment: .leading, spacing: 2) {
                Text("ExDetox")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                Text("Be Proud")
                    .font(.system(size: 9, weight: .regular, design: .rounded))
                    .opacity(0.5)
                    .italic()
            }
            
            Spacer()
        }
        .containerBackground(for: .widget) { Color.clear }
    }
    
    // MARK: - Inline Lock Screen
    private var inlineWidget: some View {
        Text("ExDetox · \(entry.data.currentStreakDays) days · Be Proud")
    }
}

// MARK: - PREVIEWS

#Preview("Small", as: .systemSmall) {
    ExDetoxHomeWidget()
} timeline: {
    ExDetoxEntry(date: .now, data: WidgetData(currentStreakDays: 7, exName: "", currentLevel: "", levelEmoji: "", levelColor: "", maxStreak: 14, lastUpdated: Date(), backgroundColor: "000000", accentColor: "FFFFFF", showExName: false))
}

#Preview("Medium", as: .systemMedium) {
    ExDetoxHomeWidget()
} timeline: {
    ExDetoxEntry(date: .now, data: WidgetData(currentStreakDays: 21, exName: "", currentLevel: "", levelEmoji: "", levelColor: "", maxStreak: 30, lastUpdated: Date(), backgroundColor: "000000", accentColor: "FFFFFF", showExName: false))
}

#Preview("Large", as: .systemLarge) {
    ExDetoxHomeWidget()
} timeline: {
    ExDetoxEntry(date: .now, data: WidgetData(currentStreakDays: 45, exName: "", currentLevel: "", levelEmoji: "", levelColor: "", maxStreak: 45, lastUpdated: Date(), backgroundColor: "000000", accentColor: "FFFFFF", showExName: false))
}

#Preview("Lock Rectangular", as: .accessoryRectangular) {
    ExDetoxLockScreenWidget()
} timeline: {
    ExDetoxEntry(date: .now, data: WidgetData(currentStreakDays: 14, exName: "", currentLevel: "", levelEmoji: "", levelColor: "", maxStreak: 14, lastUpdated: Date(), backgroundColor: "FFFFFF", accentColor: "000000", showExName: false))
}

#Preview("Lock Inline", as: .accessoryInline) {
    ExDetoxLockScreenWidget()
} timeline: {
    ExDetoxEntry(date: .now, data: WidgetData(currentStreakDays: 7, exName: "", currentLevel: "", levelEmoji: "", levelColor: "", maxStreak: 7, lastUpdated: Date(), backgroundColor: "FFFFFF", accentColor: "000000", showExName: false))
}
