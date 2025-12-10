import Foundation

enum HealingLevel: Int, CaseIterable, Codable, Hashable {
    case emergency
    case withdrawal
    case reality
    case glowUp
    case unbothered
    
    var title: String {
        switch self {
        case .emergency: return "Emergency Mode"
        case .withdrawal: return "Craving Detox"
        case .reality: return "Reality Mode"
        case .glowUp: return "Glow-Up Era"
        case .unbothered: return "Unbothered Mode"
        }
    }
    
    var subtitle: String {
        switch self {
        case .emergency: return "Heartbreak ICU. We stop the bleeding."
        case .withdrawal: return "You miss them, but you know better now."
        case .reality: return "You see the situation clearly, even if it stings."
        case .glowUp: return "More energy goes to you than to them."
        case .unbothered: return "You finished thinking about them for real."
        }
    }
    
    var genZTagline: String {
        switch self {
        case .emergency: return "Currently in my villain origin story arc"
        case .withdrawal: return "Still healing but make it fashion"
        case .reality: return "The rose-tinted glasses are off bestie"
        case .glowUp: return "You're officially the main character now"
        case .unbothered: return "Living rent-free in their head while thriving"
        }
    }
    
    var emoji: String {
        switch self {
        case .emergency: return "💔"
        case .withdrawal: return "🧠"
        case .reality: return "🪞"
        case .glowUp: return "✨"
        case .unbothered: return "🏆"
        }
    }
    
    var color: String {
        switch self {
        case .emergency: return "FF6B6B"
        case .withdrawal: return "9B59B6"
        case .reality: return "3498DB"
        case .glowUp: return "F39C12"
        case .unbothered: return "2ECC71"
        }
    }
    
    var minDays: Int {
        switch self {
        case .emergency: return 14
        case .withdrawal: return 30
        case .reality: return 60
        case .glowUp: return 90
        case .unbothered: return 0
        }
    }
    
    var maxBonusDays: Int {
        return 4
    }
    
    var index: Int {
        rawValue + 1
    }
    
    var nextLevel: HealingLevel? {
        HealingLevel(rawValue: rawValue + 1)
    }
}

enum PowerActionType: String, Codable, Hashable, CaseIterable, Identifiable {
    case deletePhotos
    case unfollowEx
    case blockEx
    case archiveChats
    case deleteNumber
    
    var id: String { rawValue }
    
    var bonusDays: Double {
        switch self {
        case .deletePhotos: return 1.0
        case .unfollowEx: return 1.0
        case .blockEx: return 1.0
        case .archiveChats: return 0.5
        case .deleteNumber: return 0.5
        }
    }
    
    var displayName: String {
        switch self {
        case .deletePhotos: return "Delete Photos"
        case .unfollowEx: return "Unfollow Them"
        case .blockEx: return "Block Them"
        case .archiveChats: return "Archive Chats"
        case .deleteNumber: return "Delete Number"
        }
    }
    
    var icon: String {
        switch self {
        case .deletePhotos: return "trash.fill"
        case .unfollowEx: return "person.badge.minus"
        case .blockEx: return "hand.raised.fill"
        case .archiveChats: return "archivebox.fill"
        case .deleteNumber: return "phone.down.fill"
        }
    }
    
    var description: String {
        switch self {
        case .deletePhotos: return "Delete their photos from your phone"
        case .unfollowEx: return "Unfollow them on social media"
        case .blockEx: return "Block them to remove temptation"
        case .archiveChats: return "Archive or delete old conversations"
        case .deleteNumber: return "Delete their number so you can't text"
        }
    }
    
    var isRepeatable: Bool {
        return false
    }
    
    static var allActions: [PowerActionType] {
        [.deletePhotos, .unfollowEx, .blockEx, .archiveChats, .deleteNumber]
    }
}

struct PowerActionRecord: Equatable, Hashable, Identifiable, Codable {
    let id: UUID
    let type: PowerActionType
    let date: Date
    var note: String?
    
    init(id: UUID = UUID(), type: PowerActionType, date: Date = Date(), note: String? = nil) {
        self.id = id
        self.type = type
        self.date = date
        self.note = note
    }
}

struct DailyCheckIn: Equatable, Hashable, Identifiable, Codable {
    let id: UUID
    let date: Date
    var mood: Int
    var urge: Int
    var note: String?
    
    init(id: UUID = UUID(), date: Date = Date(), mood: Int = 3, urge: Int = 5, note: String? = nil) {
        self.id = id
        self.date = date
        self.mood = min(max(mood, 1), 5)
        self.urge = min(max(urge, 0), 10)
        self.note = note
    }
}

enum BadgeType: String, Codable, Hashable, CaseIterable, Identifiable {
    case firstDay
    case weekStreak
    case twoWeekStreak
    case monthStreak
    case deletedFolder
    case blockedEx
    case unfollowedAll
    case glowUpReached
    case unbotheredReached
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .firstDay: return "Day One"
        case .weekStreak: return "Week Warrior"
        case .twoWeekStreak: return "Two Weeks Strong"
        case .monthStreak: return "Month Master"
        case .deletedFolder: return "Photo Purge"
        case .blockedEx: return "Blocked & Blessed"
        case .unfollowedAll: return "Digital Detox"
        case .glowUpReached: return "Glow-Up Achieved"
        case .unbotheredReached: return "Unbothered Queen"
        }
    }
    
    var emoji: String {
        switch self {
        case .firstDay: return "🌱"
        case .weekStreak: return "🔥"
        case .twoWeekStreak: return "💪"
        case .monthStreak: return "👑"
        case .deletedFolder: return "🗑️"
        case .blockedEx: return "🚫"
        case .unfollowedAll: return "📵"
        case .glowUpReached: return "💅"
        case .unbotheredReached: return "🏆"
        }
    }
    
    var genZTagline: String {
        switch self {
        case .firstDay: return "You showed up. That's the vibe."
        case .weekStreak: return "A whole week? That's giving main character."
        case .twoWeekStreak: return "Two weeks of choosing yourself. Iconic."
        case .monthStreak: return "30 days of being that person. Obsessed."
        case .deletedFolder: return "Deleted the receipts. Growth era unlocked."
        case .blockedEx: return "Blocked with love. Peace was chosen."
        case .unfollowedAll: return "Unfollowed and unbothered. As you should."
        case .glowUpReached: return "The glow-up is giving everything."
        case .unbotheredReached: return "Living rent-free in your own peace."
        }
    }
    
    var icon: String {
        switch self {
        case .firstDay: return "leaf.fill"
        case .weekStreak: return "flame.fill"
        case .twoWeekStreak: return "bolt.fill"
        case .monthStreak: return "crown.fill"
        case .deletedFolder: return "trash.fill"
        case .blockedEx: return "xmark.shield.fill"
        case .unfollowedAll: return "person.crop.circle.badge.minus"
        case .glowUpReached: return "sparkles"
        case .unbotheredReached: return "trophy.fill"
        }
    }
    
    var color: String {
        switch self {
        case .firstDay: return "34C759"
        case .weekStreak: return "FF6B35"
        case .twoWeekStreak: return "5856D6"
        case .monthStreak: return "FFD60A"
        case .deletedFolder: return "FF3B30"
        case .blockedEx: return "FF2D55"
        case .unfollowedAll: return "007AFF"
        case .glowUpReached: return "FFD700"
        case .unbotheredReached: return "30D158"
        }
    }
}

struct Badge: Equatable, Hashable, Identifiable, Codable {
    let id: UUID
    let type: BadgeType
    let earnedDate: Date
    
    init(id: UUID = UUID(), type: BadgeType, earnedDate: Date = Date()) {
        self.id = id
        self.type = type
        self.earnedDate = earnedDate
    }
}

struct TrackingState: StoreState {
    var exName: String
    var programStartDate: Date
    var totalProgramDays: Int
    
    var levelStartDate: Date
    var currentLevel: HealingLevel
    
    var noContactStartDate: Date
    var lastRelapseDate: Date?
    var relapseCount: Int
    var maxStreak: Int
    
    var bonusDays: Double
    var lifetimeBonusDays: Double
    var relapseDates: [Date]
    var powerActions: [PowerActionRecord]
    var dailyCheckIns: [DailyCheckIn]
    var badges: [Badge]
}

extension TrackingState {
    static func initialNow(totalProgramDays: Int = 180) -> TrackingState {
        let now = Date()
        return TrackingState(
            exName: "",
            programStartDate: now,
            totalProgramDays: totalProgramDays,
            levelStartDate: now,
            currentLevel: .emergency,
            noContactStartDate: now,
            lastRelapseDate: nil,
            relapseCount: 0,
            maxStreak: 0,
            bonusDays: 0,
            lifetimeBonusDays: 0,
            relapseDates: [],
            powerActions: [],
            dailyCheckIns: [],
            badges: []
        )
    }
    
    static func preview(
        programStartOffsetDays: Int,
        level: HealingLevel,
        levelOffsetDays: Int,
        noContactOffsetDays: Int? = nil,
        totalProgramDays: Int = 365,
        relapseDates: [Date] = [],
        lastRelapseDate: Date? = nil,
        relapseCount: Int = 0,
        maxStreak: Int = 0,
        bonusDays: Double = 0,
        lifetimeBonusDays: Double = 0,
        powerActions: [PowerActionRecord] = [],
        dailyCheckIns: [DailyCheckIn] = [],
        badges: [Badge] = []
    ) -> TrackingState {
        let calendar = Calendar.current
        let now = Date()
        let programStart = calendar.date(byAdding: .day, value: -programStartOffsetDays, to: now) ?? now
        let levelStart = calendar.date(byAdding: .day, value: -levelOffsetDays, to: now) ?? now
        let noContactStart = calendar.date(byAdding: .day, value: -(noContactOffsetDays ?? programStartOffsetDays), to: now) ?? programStart
        
        return TrackingState(
            exName: "Alex",
            programStartDate: programStart,
            totalProgramDays: totalProgramDays,
            levelStartDate: levelStart,
            currentLevel: level,
            noContactStartDate: noContactStart,
            lastRelapseDate: lastRelapseDate,
            relapseCount: relapseCount,
            maxStreak: maxStreak,
            bonusDays: bonusDays,
            lifetimeBonusDays: lifetimeBonusDays,
            relapseDates: relapseDates,
            powerActions: powerActions,
            dailyCheckIns: dailyCheckIns,
            badges: badges
        )
    }
    
    var calendar: Calendar {
        Calendar.current
    }
    
    var daysSinceProgramStart: Int {
        let start = calendar.startOfDay(for: programStartDate)
        let now = calendar.startOfDay(for: Date())
        let days = calendar.dateComponents([.day], from: start, to: now).day ?? 0
        return max(days + 1, 1)
    }
    
    var daysInLevel: Int {
        let start = calendar.startOfDay(for: levelStartDate)
        let now = calendar.startOfDay(for: Date())
        let days = calendar.dateComponents([.day], from: start, to: now).day ?? 0
        return max(days + 1, 1)
    }
    
    var currentStreakDays: Int {
        let start = calendar.startOfDay(for: noContactStartDate)
        let now = calendar.startOfDay(for: Date())
        let days = calendar.dateComponents([.day], from: start, to: now).day ?? 0
        return max(days + 1, 1)
    }
    
    var totalHealingDays: Int {
        currentStreakDays + Int(bonusDays)
    }
    
    var detoxProgress: Double {
        guard totalProgramDays > 0 else { return 1 }
        let clamped = min(daysSinceProgramStart, totalProgramDays)
        return Double(clamped) / Double(totalProgramDays)
    }
    
    var levelProgress: Double {
        let requiredDays = currentLevel.minDays
        guard requiredDays > 0 else { return 1 }
        let effective = min(Double(daysInLevel) + bonusDays, Double(requiredDays))
        return effective / Double(requiredDays)
    }
    
    var daysLeftInLevel: Int {
        let requiredDays = currentLevel.minDays
        guard requiredDays > 0 else { return 0 }
        let remaining = Double(requiredDays) - (Double(daysInLevel) + bonusDays)
        return max(Int(ceil(remaining)), 0)
    }
    
    var daysLeftInProgram: Int {
        max(totalProgramDays - daysSinceProgramStart, 0)
    }
    
    var speedUpDaysEarned: Double {
        bonusDays
    }
    
    var totalPowerActionsCompleted: Int {
        powerActions.count
    }
    
    var weeklyStatuses: [Int] {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else {
            return Array(repeating: 0, count: 7)
        }
        
        let normalizedRelapses = Set(relapseDates.map { calendar.startOfDay(for: $0) })
        let programStartDay = calendar.startOfDay(for: programStartDate)
        
        return (0..<7).map { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: monday) else {
                return 0
            }
            
            if day > today || day < programStartDay {
                return 0
            }
            
            let normalized = calendar.startOfDay(for: day)
            if normalizedRelapses.contains(normalized) {
                return 2
            } else {
                return 1
            }
        }
    }
    
    var todayCheckIn: DailyCheckIn? {
        let today = calendar.startOfDay(for: Date())
        return dailyCheckIns.first { calendar.isDate($0.date, inSameDayAs: today) }
    }
    
    var hasCheckedInToday: Bool {
        todayCheckIn != nil
    }
    
    var averageMoodThisWeek: Double {
        let today = calendar.startOfDay(for: Date())
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) else { return 0 }
        
        let weekCheckIns = dailyCheckIns.filter { $0.date >= weekAgo }
        guard !weekCheckIns.isEmpty else { return 0 }
        
        return Double(weekCheckIns.map(\.mood).reduce(0, +)) / Double(weekCheckIns.count)
    }
    
    var averageUrgeThisWeek: Double {
        let today = calendar.startOfDay(for: Date())
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) else { return 0 }
        
        let weekCheckIns = dailyCheckIns.filter { $0.date >= weekAgo }
        guard !weekCheckIns.isEmpty else { return 0 }
        
        return Double(weekCheckIns.map(\.urge).reduce(0, +)) / Double(weekCheckIns.count)
    }
    
    var successfulDaysThisWeek: Int {
        weeklyStatuses.filter { $0 == 1 }.count
    }
    
    var relapsesDaysThisWeek: Int {
        weeklyStatuses.filter { $0 == 2 }.count
    }
    
    var weeklyCheckIns: [DailyCheckIn?] {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else {
            return Array(repeating: nil, count: 7)
        }
        
        return (0..<7).map { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: monday) else {
                return nil
            }
            return dailyCheckIns.first { calendar.isDate($0.date, inSameDayAs: day) }
        }
    }
}

@MainActor
@Observable
final class TrackingStore: Store<TrackingState> {
    override init(state: TrackingState = .initialNow()) {
        super.init(state: state)
    }
    
    var currentLevel: HealingLevel {
        state.currentLevel
    }
    
    var weekStatuses: [Int] {
        state.weeklyStatuses
    }
    
    var weeklyCheckIns: [DailyCheckIn?] {
        state.weeklyCheckIns
    }
    
    var daysSinceProgramStart: Int {
        state.daysSinceProgramStart
    }
    
    var detoxProgress: Double {
        state.detoxProgress
    }
    
    var levelProgress: Double {
        state.levelProgress
    }
    
    var daysLeftInLevel: Int {
        state.daysLeftInLevel
    }
    
    var daysLeftInProgram: Int {
        state.daysLeftInProgram
    }
    
    var currentStreakDays: Int {
        state.currentStreakDays
    }
    
    var totalHealingDays: Int {
        state.totalHealingDays
    }
    
    var totalProgramDays: Int {
        state.totalProgramDays
    }
    
    var relapses: Int {
        state.relapseCount
    }
    
    var maxStreak: Int {
        state.maxStreak
    }
    
    var bonusDays: Double {
        state.bonusDays
    }
    
    var lifetimeBonusDays: Double {
        state.lifetimeBonusDays
    }
    
    var daysInLevel: Int {
        state.daysInLevel
    }
    
    var powerActions: [PowerActionRecord] {
        state.powerActions
    }
    
    var badges: [Badge] {
        state.badges
    }
    
    var dailyCheckIns: [DailyCheckIn] {
        state.dailyCheckIns
    }
    
    var hasCheckedInToday: Bool {
        state.hasCheckedInToday
    }
    
    var todayCheckIn: DailyCheckIn? {
        state.todayCheckIn
    }
    
    var freedomDate: Date {
        state.calendar.date(byAdding: .day, value: state.totalProgramDays, to: state.programStartDate) ?? Date()
    }
    
    func updateForCurrentDate(_ date: Date = Date()) {
        updateLevelIfNeeded(currentDate: date)
        checkAndAwardBadges()
    }
    
    func recordRelapse(on date: Date = Date()) {
        let calendar = state.calendar
        let today = calendar.startOfDay(for: date)
        
        let previousStreak = state.currentStreakDays
        if previousStreak > state.maxStreak {
            state.maxStreak = previousStreak
        }
        
        state.lastRelapseDate = today
        state.noContactStartDate = today
        state.relapseCount += 1
        
        if !state.relapseDates.contains(where: { calendar.isDate($0, inSameDayAs: today) }) {
            state.relapseDates.append(today)
        }
        
        state.levelStartDate = today
        state.bonusDays = 0
    }
    
    func recordPowerAction(_ type: PowerActionType, on date: Date = Date(), note: String? = nil) {
        if !type.isRepeatable && state.powerActions.contains(where: { $0.type == type }) {
            return
        }
        
        let record = PowerActionRecord(type: type, date: date, note: note)
        state.powerActions.append(record)
        
        let maxBonus = state.currentLevel.maxBonusDays
        let updated = min(state.bonusDays + type.bonusDays, Double(maxBonus))
        state.bonusDays = updated
        state.lifetimeBonusDays += type.bonusDays
        
        updateLevelIfNeeded(currentDate: date)
        checkAndAwardBadges()
    }
    
    func recordDailyCheckIn(mood: Int, urge: Int, note: String? = nil, on date: Date = Date()) {
        let calendar = state.calendar
        let today = calendar.startOfDay(for: date)
        
        if let existingIndex = state.dailyCheckIns.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            state.dailyCheckIns[existingIndex].mood = mood
            state.dailyCheckIns[existingIndex].urge = urge
            state.dailyCheckIns[existingIndex].note = note
        } else {
            let checkIn = DailyCheckIn(date: today, mood: mood, urge: urge, note: note)
            state.dailyCheckIns.append(checkIn)
        }
    }
    
    private func updateLevelIfNeeded(currentDate: Date) {
        let requiredDays = state.currentLevel.minDays
        guard requiredDays > 0 else { return }
        
        let effective = Double(state.daysInLevel) + state.bonusDays
        guard effective >= Double(requiredDays) else { return }
        
        guard let nextLevel = HealingLevel(rawValue: state.currentLevel.rawValue + 1) else { return }
        
        state.currentLevel = nextLevel
        state.levelStartDate = currentDate
        state.bonusDays = 0
    }
    
    private func checkAndAwardBadges() {
        let earnedTypes = Set(state.badges.map(\.type))
        
        if state.currentStreakDays >= 1 && !earnedTypes.contains(.firstDay) {
            state.badges.append(Badge(type: .firstDay))
        }
        
        if state.currentStreakDays >= 7 && !earnedTypes.contains(.weekStreak) {
            state.badges.append(Badge(type: .weekStreak))
        }
        
        if state.currentStreakDays >= 14 && !earnedTypes.contains(.twoWeekStreak) {
            state.badges.append(Badge(type: .twoWeekStreak))
        }
        
        if state.currentStreakDays >= 30 && !earnedTypes.contains(.monthStreak) {
            state.badges.append(Badge(type: .monthStreak))
        }
        
        if state.powerActions.contains(where: { $0.type == .deletePhotos }) && !earnedTypes.contains(.deletedFolder) {
            state.badges.append(Badge(type: .deletedFolder))
        }
        
        if state.powerActions.contains(where: { $0.type == .blockEx }) && !earnedTypes.contains(.blockedEx) {
            state.badges.append(Badge(type: .blockedEx))
        }
        
        if state.powerActions.contains(where: { $0.type == .unfollowEx }) && !earnedTypes.contains(.unfollowedAll) {
            state.badges.append(Badge(type: .unfollowedAll))
        }
        
        if state.currentLevel.rawValue >= HealingLevel.glowUp.rawValue && !earnedTypes.contains(.glowUpReached) {
            state.badges.append(Badge(type: .glowUpReached))
        }
        
        if state.currentLevel == .unbothered && !earnedTypes.contains(.unbotheredReached) {
            state.badges.append(Badge(type: .unbotheredReached))
        }
    }
    
    func awardBadge(_ type: BadgeType) {
        guard !state.badges.contains(where: { $0.type == type }) else { return }
        state.badges.append(Badge(type: type))
    }
    
    func resetProgress() {
        let now = Date()
        let previousStreak = state.currentStreakDays
        if previousStreak > state.maxStreak {
            state.maxStreak = previousStreak
        }
        
        state.noContactStartDate = now
        state.levelStartDate = now
        state.currentLevel = .emergency
        state.bonusDays = 0
        state.relapseCount += 1
        state.lastRelapseDate = now
        
        let today = state.calendar.startOfDay(for: now)
        if !state.relapseDates.contains(where: { state.calendar.isDate($0, inSameDayAs: today) }) {
            state.relapseDates.append(today)
        }
    }
}

extension TrackingStore {
    static var previewNewUser: TrackingStore {
        TrackingStore(state: .preview(
            programStartOffsetDays: 0,
            level: .emergency,
            levelOffsetDays: 0,
            noContactOffsetDays: 0
        ))
    }
    
    static var previewLevel1: TrackingStore {
        let calendar = Calendar.current
        let now = Date()
        
        let checkIns = (0..<3).compactMap { offset -> DailyCheckIn? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: now) else { return nil }
            return DailyCheckIn(date: date, mood: 2 + offset, urge: 8 - offset)
        }
        
        let state = TrackingState.preview(
            programStartOffsetDays: 3,
            level: .emergency,
            levelOffsetDays: 3,
            noContactOffsetDays: 3,
            dailyCheckIns: checkIns,
            badges: [Badge(type: .firstDay)]
        )
        
        return TrackingStore(state: state)
    }
    
    static var previewLevel2WithProgress: TrackingStore {
        let calendar = Calendar.current
        let now = Date()
        
        let powerActions = [
            PowerActionRecord(type: .muteNotifications, date: calendar.date(byAdding: .day, value: -10, to: now) ?? now),
            PowerActionRecord(type: .deletePhotos, date: calendar.date(byAdding: .day, value: -7, to: now) ?? now),
            PowerActionRecord(type: .unfollowOne, date: calendar.date(byAdding: .day, value: -5, to: now) ?? now)
        ]
        
        let checkIns = (0..<14).compactMap { offset -> DailyCheckIn? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: now) else { return nil }
            let mood = min(5, 2 + (offset / 3))
            let urge = max(0, 9 - offset)
            return DailyCheckIn(date: date, mood: mood, urge: urge)
        }
        
        let badges = [
            Badge(type: .firstDay, earnedDate: calendar.date(byAdding: .day, value: -17, to: now) ?? now),
            Badge(type: .weekStreak, earnedDate: calendar.date(byAdding: .day, value: -10, to: now) ?? now),
            Badge(type: .twoWeekStreak, earnedDate: calendar.date(byAdding: .day, value: -3, to: now) ?? now),
            Badge(type: .deletedFolder, earnedDate: calendar.date(byAdding: .day, value: -7, to: now) ?? now)
        ]
        
        let state = TrackingState.preview(
            programStartOffsetDays: 18,
            level: .withdrawal,
            levelOffsetDays: 4,
            noContactOffsetDays: 18,
            maxStreak: 18,
            bonusDays: 1.75,
            powerActions: powerActions,
            dailyCheckIns: checkIns,
            badges: badges
        )
        
        return TrackingStore(state: state)
    }
    
    static var previewLevel3WithRelapses: TrackingStore {
        let calendar = Calendar.current
        let now = Date()
        let relapse1 = calendar.date(byAdding: .day, value: -2, to: now) ?? now
        let relapse2 = calendar.date(byAdding: .day, value: -5, to: now) ?? now
        
        let powerActions = [
            PowerActionRecord(type: .deletePhotos, date: calendar.date(byAdding: .day, value: -30, to: now) ?? now),
            PowerActionRecord(type: .unfollow, date: calendar.date(byAdding: .day, value: -25, to: now) ?? now),
            PowerActionRecord(type: .realityJournaling, date: calendar.date(byAdding: .day, value: -20, to: now) ?? now),
            PowerActionRecord(type: .block, date: calendar.date(byAdding: .day, value: -10, to: now) ?? now)
        ]
        
        let checkIns = (0..<7).compactMap { offset -> DailyCheckIn? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: now) else { return nil }
            let isRelapseDay = offset == 2 || offset == 5
            return DailyCheckIn(date: date, mood: isRelapseDay ? 1 : 3, urge: isRelapseDay ? 10 : 4)
        }
        
        let badges = [
            Badge(type: .firstDay),
            Badge(type: .weekStreak),
            Badge(type: .twoWeekStreak),
            Badge(type: .deletedFolder),
            Badge(type: .blockedEx),
            Badge(type: .unfollowedAll),
            Badge(type: .firstJournal)
        ]
        
        let state = TrackingState.preview(
            programStartOffsetDays: 45,
            level: .reality,
            levelOffsetDays: 20,
            noContactOffsetDays: 2,
            relapseDates: [relapse1, relapse2],
            lastRelapseDate: relapse1,
            relapseCount: 4,
            maxStreak: 18,
            bonusDays: 2,
            powerActions: powerActions,
            dailyCheckIns: checkIns,
            badges: badges
        )
        
        return TrackingStore(state: state)
    }
    
    static var previewLevel4NearLevelUp: TrackingStore {
        let calendar = Calendar.current
        let now = Date()
        
        let powerActions = (0..<12).compactMap { offset -> PowerActionRecord? in
            guard let date = calendar.date(byAdding: .day, value: -offset * 5, to: now) else { return nil }
            let types: [PowerActionType] = [.deletePhotos, .realityJournaling, .newExperience, .socialActivity, .fitnessChallenge]
            return PowerActionRecord(type: types[offset % types.count], date: date)
        }
        
        let checkIns = (0..<30).compactMap { offset -> DailyCheckIn? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: now) else { return nil }
            return DailyCheckIn(date: date, mood: min(5, 3 + (offset / 10)), urge: max(1, 5 - (offset / 7)))
        }
        
        let badges: [Badge] = [
            Badge(type: .firstDay),
            Badge(type: .weekStreak),
            Badge(type: .twoWeekStreak),
            Badge(type: .monthStreak),
            Badge(type: .deletedFolder),
            Badge(type: .blockedEx),
            Badge(type: .unfollowedAll),
            Badge(type: .firstJournal),
            Badge(type: .newExperience)
        ]
        
        let state = TrackingState.preview(
            programStartOffsetDays: 150,
            level: .glowUp,
            levelOffsetDays: 85,
            noContactOffsetDays: 120,
            relapseCount: 2,
            maxStreak: 120,
            bonusDays: 10,
            powerActions: powerActions,
            dailyCheckIns: checkIns,
            badges: badges
        )
        
        return TrackingStore(state: state)
    }
    
    static var previewLevel5: TrackingStore {
        let calendar = Calendar.current
        let now = Date()
        
        let powerActions = (0..<20).compactMap { offset -> PowerActionRecord? in
            guard let date = calendar.date(byAdding: .day, value: -offset * 7, to: now) else { return nil }
            let types: [PowerActionType] = [.deletePhotos, .unfollow, .block, .realityJournaling, .newExperience, .socialActivity, .fitnessChallenge, .helpOthers]
            return PowerActionRecord(type: types[offset % types.count], date: date)
        }
        
        let checkIns = (0..<60).compactMap { offset -> DailyCheckIn? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: now) else { return nil }
            return DailyCheckIn(date: date, mood: 5, urge: max(0, 2 - (offset / 30)))
        }
        
        let badges = BadgeType.allCases.map { Badge(type: $0) }
        
        let state = TrackingState(
            exName: "Alex",
            programStartDate: calendar.date(byAdding: .day, value: -200, to: now) ?? now,
            totalProgramDays: 365,
            levelStartDate: calendar.date(byAdding: .day, value: -10, to: now) ?? now,
            currentLevel: .unbothered,
            noContactStartDate: calendar.date(byAdding: .day, value: -180, to: now) ?? now,
            lastRelapseDate: calendar.date(byAdding: .day, value: -180, to: now),
            relapseCount: 3,
            maxStreak: 180,
            bonusDays: 0,
            lifetimeBonusDays: 25,
            relapseDates: [],
            powerActions: powerActions,
            dailyCheckIns: checkIns,
            badges: badges
        )
        
        return TrackingStore(state: state)
    }
    
    static var previewJustRelapsed: TrackingStore {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        
        let powerActions = [
            PowerActionRecord(type: .deletePhotos, date: calendar.date(byAdding: .day, value: -20, to: now) ?? now),
            PowerActionRecord(type: .unfollow, date: calendar.date(byAdding: .day, value: -15, to: now) ?? now)
        ]
        
        let badges = [
            Badge(type: .firstDay),
            Badge(type: .weekStreak),
            Badge(type: .deletedFolder)
        ]
        
        let state = TrackingState.preview(
            programStartOffsetDays: 25,
            level: .emergency,
            levelOffsetDays: 0,
            noContactOffsetDays: 0,
            relapseDates: [today],
            lastRelapseDate: today,
            relapseCount: 3,
            maxStreak: 12,
            bonusDays: 0,
            powerActions: powerActions,
            badges: badges
        )
        
        return TrackingStore(state: state)
    }
}
