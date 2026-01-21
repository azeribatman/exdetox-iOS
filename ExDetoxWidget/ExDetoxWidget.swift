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

// MARK: - Timeline Entry

struct ExDetoxEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

// MARK: - Timeline Provider

struct ExDetoxTimelineProvider: TimelineProvider {
    private let dataProvider = WidgetDataProvider()
    
    func placeholder(in context: Context) -> ExDetoxEntry {
        ExDetoxEntry(date: Date(), data: .empty)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ExDetoxEntry) -> Void) {
        let entry = ExDetoxEntry(date: Date(), data: dataProvider.getWidgetData())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ExDetoxEntry>) -> Void) {
        let currentDate = Date()
        let entry = ExDetoxEntry(date: currentDate, data: dataProvider.getWidgetData())
        
        // Refresh every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
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
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Home Screen Widget Views

struct SmallWidgetView: View {
    let entry: ExDetoxEntry
    
    var body: some View {
        ZStack {
            Color(hex: entry.data.backgroundColor)
            
            VStack(spacing: 8) {
                Text(entry.data.levelEmoji)
                    .font(.system(size: 32))
                
                Text("\(entry.data.currentStreakDays)")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: entry.data.accentColor))
                
                Text("days free")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: entry.data.accentColor).opacity(0.6))
            }
        }
        .containerBackground(for: .widget) {
            Color(hex: entry.data.backgroundColor)
        }
    }
}

struct MediumWidgetView: View {
    let entry: ExDetoxEntry
    
    var body: some View {
        ZStack {
            Color(hex: entry.data.backgroundColor)
            
            HStack(spacing: 20) {
                // Left side - Streak
                VStack(spacing: 4) {
                    Text(entry.data.levelEmoji)
                        .font(.system(size: 36))
                    
                    Text("\(entry.data.currentStreakDays)")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: entry.data.accentColor))
                    
                    Text("days free")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: entry.data.accentColor).opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                
                // Divider
                Rectangle()
                    .fill(Color(hex: entry.data.accentColor).opacity(0.1))
                    .frame(width: 1)
                    .padding(.vertical, 16)
                
                // Right side - Level info
                VStack(alignment: .leading, spacing: 8) {
                    Text("CURRENT LEVEL")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1)
                        .foregroundStyle(Color(hex: entry.data.accentColor).opacity(0.5))
                    
                    Text(entry.data.currentLevel)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: entry.data.levelColor))
                        .lineLimit(2)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(hex: "FFD60A"))
                        Text("Best: \(entry.data.maxStreak)")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(hex: entry.data.accentColor).opacity(0.7))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
        }
        .containerBackground(for: .widget) {
            Color(hex: entry.data.backgroundColor)
        }
    }
}

struct LargeWidgetView: View {
    let entry: ExDetoxEntry
    
    var body: some View {
        ZStack {
            Color(hex: entry.data.backgroundColor)
            
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("ExDetox")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: entry.data.accentColor).opacity(0.5))
                    
                    Spacer()
                    
                    Text(entry.data.levelEmoji)
                        .font(.system(size: 24))
                }
                
                Spacer()
                
                // Main streak display
                VStack(spacing: 8) {
                    Text("\(entry.data.currentStreakDays)")
                        .font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: entry.data.accentColor))
                    
                    Text("DAYS FREE")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .tracking(3)
                        .foregroundStyle(Color(hex: entry.data.accentColor).opacity(0.6))
                }
                
                Spacer()
                
                // Level card
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CURRENT LEVEL")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(1)
                            .foregroundStyle(Color(hex: entry.data.accentColor).opacity(0.5))
                        
                        Text(entry.data.currentLevel)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: entry.data.levelColor))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("BEST STREAK")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(1)
                            .foregroundStyle(Color(hex: entry.data.accentColor).opacity(0.5))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(hex: "FFD60A"))
                            Text("\(entry.data.maxStreak) days")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(hex: entry.data.accentColor))
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(hex: entry.data.accentColor).opacity(0.05))
                )
            }
            .padding(20)
        }
        .containerBackground(for: .widget) {
            Color(hex: entry.data.backgroundColor)
        }
    }
}

// MARK: - Lock Screen Widget Views

struct CircularLockScreenView: View {
    let entry: ExDetoxEntry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            VStack(spacing: 0) {
                Text("\(entry.data.currentStreakDays)")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.5)
                
                Text("days")
                    .font(.system(size: 8, weight: .semibold, design: .rounded))
                    .opacity(0.7)
            }
        }
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
    }
}

struct RectangularLockScreenView: View {
    let entry: ExDetoxEntry
    
    var body: some View {
        HStack(spacing: 8) {
            Text(entry.data.levelEmoji)
                .font(.system(size: 28))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.data.currentStreakDays) days free")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                
                Text(entry.data.currentLevel)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .opacity(0.7)
            }
            
            Spacer()
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct InlineLockScreenView: View {
    let entry: ExDetoxEntry
    
    var body: some View {
        HStack(spacing: 4) {
            Text(entry.data.levelEmoji)
            Text("\(entry.data.currentStreakDays) days free")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
        }
    }
}

// MARK: - Home Screen Widget

struct ExDetoxHomeWidget: Widget {
    let kind: String = "ExDetoxHomeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ExDetoxTimelineProvider()) { entry in
            ExDetoxHomeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Streak Tracker")
        .description("Track your no-contact streak at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct ExDetoxHomeWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: ExDetoxEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Lock Screen Widget

struct ExDetoxLockScreenWidget: Widget {
    let kind: String = "ExDetoxLockScreenWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ExDetoxTimelineProvider()) { entry in
            ExDetoxLockScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Streak Counter")
        .description("See your streak on your lock screen.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct ExDetoxLockScreenWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: ExDetoxEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularLockScreenView(entry: entry)
        case .accessoryRectangular:
            RectangularLockScreenView(entry: entry)
        case .accessoryInline:
            InlineLockScreenView(entry: entry)
        default:
            CircularLockScreenView(entry: entry)
        }
    }
}

// MARK: - Widget Bundle

@main
struct ExDetoxWidgetBundle: WidgetBundle {
    var body: some Widget {
        ExDetoxHomeWidget()
        ExDetoxLockScreenWidget()
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    ExDetoxHomeWidget()
} timeline: {
    ExDetoxEntry(date: .now, data: WidgetData(
        currentStreakDays: 7,
        exName: "Alex",
        currentLevel: "Emergency Mode",
        levelEmoji: "💔",
        levelColor: "FF6B6B",
        maxStreak: 14,
        lastUpdated: Date(),
        backgroundColor: "FFFFFF",
        accentColor: "000000",
        showExName: false
    ))
}

#Preview("Medium", as: .systemMedium) {
    ExDetoxHomeWidget()
} timeline: {
    ExDetoxEntry(date: .now, data: WidgetData(
        currentStreakDays: 21,
        exName: "Alex",
        currentLevel: "Craving Detox",
        levelEmoji: "🧠",
        levelColor: "9B59B6",
        maxStreak: 30,
        lastUpdated: Date(),
        backgroundColor: "FFFFFF",
        accentColor: "000000",
        showExName: false
    ))
}

#Preview("Circular", as: .accessoryCircular) {
    ExDetoxLockScreenWidget()
} timeline: {
    ExDetoxEntry(date: .now, data: .empty)
}

#Preview("Rectangular", as: .accessoryRectangular) {
    ExDetoxLockScreenWidget()
} timeline: {
    ExDetoxEntry(date: .now, data: WidgetData(
        currentStreakDays: 7,
        exName: "Alex",
        currentLevel: "Emergency Mode",
        levelEmoji: "💔",
        levelColor: "FF6B6B",
        maxStreak: 14,
        lastUpdated: Date(),
        backgroundColor: "FFFFFF",
        accentColor: "000000",
        showExName: false
    ))
}
