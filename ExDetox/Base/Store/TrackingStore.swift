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
        switch self {
        case .emergency: return 4
        case .withdrawal: return 6
        case .reality: return 10
        case .glowUp: return 14
        case .unbothered: return 0
        }
    }
    
    var index: Int {
        rawValue + 1
    }
    
    var nextLevel: HealingLevel? {
        HealingLevel(rawValue: rawValue + 1)
    }
    
    var challenges: [PowerActionType] {
        switch self {
        case .emergency:
            return [.deletePhotos, .unfollowOne, .muteNotifications, .archiveChats, .drinkWater]
        case .withdrawal:
            return [.unfollow, .realityJournaling, .cleanRoom, .readBook, .walkOutside]
        case .reality:
            return [.block, .standardsList, .trashGifts, .changeWallpaper, .cookMeal]
        case .glowUp:
            return [.newExperience, .socialActivity, .fitnessChallenge, .dressUp, .listenNewMusic]
        case .unbothered:
            return [.newExperience, .helpOthers, .deleteNumber]
        }
    }
}

enum PowerActionType: String, Codable, Hashable, CaseIterable, Identifiable {
    case deletePhotos
    case unfollow
    case unfollowOne
    case block
    case realityJournaling
    case newExperience
    case muteNotifications
    case standardsList
    case socialActivity
    case fitnessChallenge
    case helpOthers
    case deleteNumber
    case archiveChats
    case cleanRoom
    case trashGifts
    case changeWallpaper
    case readBook
    case walkOutside
    case dressUp
    case cookMeal
    case listenNewMusic
    case drinkWater
    case custom
    
    var id: String { rawValue }
    
    var bonusDays: Double {
        switch self {
        case .deletePhotos, .block, .deleteNumber, .trashGifts:
            return 2.0
        case .unfollow, .unfollowOne, .helpOthers, .newExperience, .socialActivity, .fitnessChallenge, .archiveChats:
            return 1.0
        case .realityJournaling, .standardsList, .cleanRoom, .readBook, .walkOutside, .dressUp, .cookMeal, .listenNewMusic, .changeWallpaper, .custom, .muteNotifications, .drinkWater:
            return 0.5
        }
    }
    
    var displayName: String {
        switch self {
        case .deletePhotos: return "Deleted Photos"
        case .unfollow: return "Unfollowed"
        case .unfollowOne: return "Unfollowed 1 Account"
        case .block: return "Blocked"
        case .realityJournaling: return "Reality Journaling"
        case .newExperience: return "New Experience"
        case .muteNotifications: return "Muted Notifications"
        case .standardsList: return "Wrote Standards List"
        case .socialActivity: return "Social Activity"
        case .fitnessChallenge: return "Fitness Challenge"
        case .helpOthers: return "Helped Others Heal"
        case .deleteNumber: return "Deleted Number"
        case .archiveChats: return "Archived Chats"
        case .cleanRoom: return "Cleaned Room"
        case .trashGifts: return "Trashed Gifts"
        case .changeWallpaper: return "Changed Wallpaper"
        case .readBook: return "Read a Book"
        case .walkOutside: return "Went for a Walk"
        case .dressUp: return "Dressed Up"
        case .cookMeal: return "Cooked a Meal"
        case .listenNewMusic: return "New Music"
        case .drinkWater: return "Drank Water"
        case .custom: return "Custom Action"
        }
    }
    
    var icon: String {
        switch self {
        case .deletePhotos: return "trash.fill"
        case .unfollow, .unfollowOne: return "person.badge.minus"
        case .block: return "hand.raised.fill"
        case .realityJournaling: return "book.fill"
        case .newExperience: return "star.fill"
        case .muteNotifications: return "bell.slash.fill"
        case .standardsList: return "checklist"
        case .socialActivity: return "person.2.fill"
        case .fitnessChallenge: return "figure.run"
        case .helpOthers: return "heart.fill"
        case .deleteNumber: return "phone.down.fill"
        case .archiveChats: return "archivebox.fill"
        case .cleanRoom: return "sparkles"
        case .trashGifts: return "gift.fill"
        case .changeWallpaper: return "photo.fill"
        case .readBook: return "book.closed.fill"
        case .walkOutside: return "figure.walk"
        case .dressUp: return "tshirt.fill"
        case .cookMeal: return "fork.knife"
        case .listenNewMusic: return "music.note"
        case .drinkWater: return "drop.fill"
        case .custom: return "sparkles"
        }
    }
    
    var description: String {
        switch self {
        case .deletePhotos: return "Delete photos of your ex from your phone"
        case .unfollow: return "Unfollow your ex on all platforms"
        case .unfollowOne: return "Unfollow your ex on one platform"
        case .block: return "Block your ex to remove temptation"
        case .realityJournaling: return "Write about the real relationship, not the fantasy"
        case .newExperience: return "Try something new you've been putting off"
        case .muteNotifications: return "Mute notifications from apps that remind you of them"
        case .standardsList: return "Write your non-negotiables for future relationships"
        case .socialActivity: return "Hang out with friends or meet new people"
        case .fitnessChallenge: return "Complete a workout or physical challenge"
        case .helpOthers: return "Help someone else going through heartbreak"
        case .deleteNumber: return "Delete their number so you can't text them"
        case .archiveChats: return "Archive or delete old chat history"
        case .cleanRoom: return "Clean your space to clear your mind"
        case .trashGifts: return "Get rid of gifts that remind you of them"
        case .changeWallpaper: return "Change your wallpaper if it reminds you of them"
        case .readBook: return "Read a few pages of a book to distract yourself"
        case .walkOutside: return "Go for a walk and get some fresh air"
        case .dressUp: return "Put on an outfit that makes you feel confident"
        case .cookMeal: return "Cook a healthy meal for yourself"
        case .listenNewMusic: return "Listen to new music, not sad songs"
        case .drinkWater: return "Stay hydrated and take care of your body"
        case .custom: return "A personal healing action you defined"
        }
    }
    
    var isRepeatable: Bool {
        switch self {
        case .deletePhotos, .unfollow, .block, .muteNotifications, .standardsList, .deleteNumber, .archiveChats, .trashGifts, .changeWallpaper:
            return false
        default:
            return true
        }
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
    case firstJournal
    case newExperience
    case glowUpReached
    case unbotheredReached
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .firstDay: return "Day One"
        case .weekStreak: return "Week Warrior"
        case .twoWeekStreak: return "Two Weeks Strong"
        case .monthStreak: return "30 Days No Contact"
        case .deletedFolder: return "Deleted the Folder"
        case .blockedEx: return "Blocked & Blessed"
        case .unfollowedAll: return "Digital Detox"
        case .firstJournal: return "Reality Check"
        case .newExperience: return "New Chapter"
        case .glowUpReached: return "Glow-Up Achieved"
        case .unbotheredReached: return "Unbothered Era"
        }
    }
    
    var icon: String {
        switch self {
        case .firstDay: return "1.circle.fill"
        case .weekStreak: return "7.circle.fill"
        case .twoWeekStreak: return "14.circle.fill"
        case .monthStreak: return "30.circle.fill"
        case .deletedFolder: return "folder.badge.minus"
        case .blockedEx: return "hand.raised.fill"
        case .unfollowedAll: return "person.2.slash.fill"
        case .firstJournal: return "book.closed.fill"
        case .newExperience: return "star.fill"
        case .glowUpReached: return "sparkles"
        case .unbotheredReached: return "crown.fill"
        }
    }
    
    var color: String {
        switch self {
        case .firstDay: return "9B59B6"
        case .weekStreak: return "3498DB"
        case .twoWeekStreak: return "1ABC9C"
        case .monthStreak: return "F39C12"
        case .deletedFolder: return "E74C3C"
        case .blockedEx: return "E91E63"
        case .unfollowedAll: return "00BCD4"
        case .firstJournal: return "8E44AD"
        case .newExperience: return "FF9800"
        case .glowUpReached: return "FFD700"
        case .unbotheredReached: return "2ECC71"
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
        return max(calendar.dateComponents([.day], from: start, to: now).day ?? 0, 0)
    }
    
    var daysInLevel: Int {
        let start = calendar.startOfDay(for: levelStartDate)
        let now = calendar.startOfDay(for: Date())
        return max(calendar.dateComponents([.day], from: start, to: now).day ?? 0, 0)
    }
    
    var currentStreakDays: Int {
        let start = calendar.startOfDay(for: noContactStartDate)
        let now = calendar.startOfDay(for: Date())
        return max(calendar.dateComponents([.day], from: start, to: now).day ?? 0, 0)
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
        // Prevent duplicates for non-repeatable actions
        if !type.isRepeatable && state.powerActions.contains(where: { $0.type == type }) {
            return
        }
        
        let record = PowerActionRecord(type: type, date: date, note: note)
        state.powerActions.append(record)
        
        let maxBonus = state.currentLevel.maxBonusDays
        let updated = min(state.bonusDays + type.bonusDays, Double(maxBonus))
        state.bonusDays = updated
        
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
        
        if state.powerActions.contains(where: { $0.type == .block }) && !earnedTypes.contains(.blockedEx) {
            state.badges.append(Badge(type: .blockedEx))
        }
        
        if state.powerActions.contains(where: { $0.type == .unfollow }) && !earnedTypes.contains(.unfollowedAll) {
            state.badges.append(Badge(type: .unfollowedAll))
        }
        
        if state.powerActions.contains(where: { $0.type == .realityJournaling }) && !earnedTypes.contains(.firstJournal) {
            state.badges.append(Badge(type: .firstJournal))
        }
        
        if state.powerActions.contains(where: { $0.type == .newExperience }) && !earnedTypes.contains(.newExperience) {
            state.badges.append(Badge(type: .newExperience))
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
