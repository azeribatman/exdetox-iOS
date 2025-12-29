import SwiftUI
import Combine
import SwiftData
import AppsFlyerLib

struct HomeView: View {
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(NotificationStore.self) private var notificationStore
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(\.modelContext) private var modelContext
    
    let weekDays = ["M", "T", "W", "T", "F", "S", "S"]
    
    @State private var timeComponents: (days: String, hours: String, minutes: String, seconds: String) = ("00", "00", "00", "00")
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var showSettings = false
    @State private var showRoastMe = false
    @State private var showMeditate = false
    @State private var showPanic = false
    @State private var showRelapseConfirm = false
    @State private var showCheckInSheet = false
    @State private var showPowerActionsSheet = false
    @State private var stickyQuote: String = ""
    
    private let creamBg = Color(hex: "F5F0E8")
    private let cardBg = Color(hex: "FFFDF9")
    
    private var userName: String {
        let name = userProfileStore.profile.name
        return name.isEmpty ? "Friend" : name
    }
    
    private var exName: String {
        let name = userProfileStore.profile.exName
        return name.isEmpty ? "them" : name
    }
    
    private var exPronoun: String {
        userProfileStore.profile.pronounForEx
    }
    
    private var exGenderKey: String {
        let gender = userProfileStore.profile.exGender.lowercased()
        if gender.contains("male") && !gender.contains("female") {
            return "male"
        } else if gender.contains("female") {
            return "female"
        } else {
            return "other"
        }
    }
    
    private func loadDailyQuotes() -> [String] {
        guard let url = Bundle.main.url(forResource: "dailyQuotes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let quotes = json["quotes"] as? [String: [String: [String]]],
              let genderQuotes = quotes[exGenderKey],
              let levelQuotes = genderQuotes[trackingStore.currentLevel.rawValue] else {
            return defaultQuotes
        }
        
        return levelQuotes.map { quote in
            quote
                .replacingOccurrences(of: "{exName}", with: exName)
                .replacingOccurrences(of: "{pronoun}", with: exPronoun)
        }
    }
    
    private var defaultQuotes: [String] {
        switch trackingStore.currentLevel {
        case .emergency:
            return [
                "\(exName)'s probably scrolling through reels rn. You should slay your goals instead 💅",
                "Main character energy: activated. \(exName): deleted from the storyline 🎬",
                "You're in your villain arc. Channel that energy into something iconic ✨"
            ]
        case .withdrawal:
            return [
                "Missing \(exName)? That's just your brain being dramatic. Don't let it win 🧠",
                "The urge to text will pass. The regret won't. Stay strong bestie 💪",
                "Every hour you don't text \(exName) is a W. Keep stacking those wins 🏆"
            ]
        case .reality:
            return [
                "Remember: you're missing \(exName)'s highlight reel, not the behind-the-scenes 🎭",
                "The rose-colored glasses are off. Now you see \(exName) for who \(exPronoun) really is 🪞",
                "You're not healing too slow. You're healing at exactly the right pace 🌱"
            ]
        case .glowUp:
            return [
                "You're literally glowing. \(exName) would be shook if \(exPronoun) saw you now ✨",
                "Plot twist: the best relationship you'll ever have is with yourself 💕",
                "Main character? You're the whole studio. \(exName) was just an extra 🎬"
            ]
        case .unbothered:
            return [
                "Living rent-free in \(exName)'s head while thriving in your own life 🏠",
                "You've unlocked: peace. It's giving unbothered energy 😌",
                "\(exName) is a closed chapter. You're writing a whole new book 📖"
            ]
        }
    }
    
    private var dailyQuotes: [String] {
        loadDailyQuotes()
    }
    
    private var randomQuote: String {
        dailyQuotes.randomElement() ?? dailyQuotes[0]
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    streakHeroCard
                    
                    actionsRow
                    
                    weeklyCard
                    
                    levelProgressCard
                    
                    if !trackingStore.hasCheckedInToday {
                        checkInPromptCard
                    }
                    
                    if !stickyQuote.isEmpty {
                        quoteCard
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .background(creamBg.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            panicButtonView
        }
        .onReceive(timer) { _ in
            updateTimer()
        }
        .onAppear {
            trackingStore.updateForCurrentDate()
            updateTimer()
            if stickyQuote.isEmpty {
                stickyQuote = randomQuote
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: .checkStreakCelebration, object: nil)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showRoastMe) {
            RoastMeView()
        }
        .sheet(isPresented: $showMeditate) {
            MeditateView()
        }
        .sheet(isPresented: $showPanic) {
            PanicView()
        }
        .sheet(isPresented: $showCheckInSheet) {
            QuickCheckInSheet()
        }
        .sheet(isPresented: $showPowerActionsSheet) {
            PowerActionsSheet()
        }
        .confirmationDialog(
            "Break No-Contact?",
            isPresented: $showRelapseConfirm,
            titleVisibility: .visible
        ) {
            Button("Yes, I broke no-contact", role: .destructive) {
                withAnimation {
                    TrackingPersistence.recordRelapse(store: trackingStore, context: modelContext)
                    notificationStore.showRelapseSupport()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will reset your streak. It's okay—slipping doesn't erase your progress. We're here to help you rebuild.")
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack(alignment: .center) {
            Text("exdetox")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 40, height: 40)
                    .background(cardBg)
                    .clipShape(Circle())
            }
            
            Button(action: { showCheckInSheet = true }) {
                if let todayMood = trackingStore.todayCheckIn?.mood {
                    Text(moodEmoji(todayMood))
                        .font(.system(size: 22))
                        .frame(width: 40, height: 40)
                        .background(cardBg)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(width: 40, height: 40)
                        .background(cardBg)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // MARK: - Streak Hero Card
    
    private var streakHeroCard: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🔥 \(trackingStore.currentStreakDays) day streak")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.orange)
                    
                    Text("Hey \(userName),")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(trackingStore.currentLevel.emoji)
                    .font(.system(size: 36))
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(timeComponents.days)
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText(value: Double(timeComponents.days) ?? 0))
                
                Text("days free")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 12)
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                timerUnit(value: timeComponents.hours, label: "hrs")
                timerUnit(value: timeComponents.minutes, label: "min")
                timerUnit(value: timeComponents.seconds, label: "sec")
                Spacer()
            }
        }
        .padding(20)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
    }
    
    private func timerUnit(value: String, label: String) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 3) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(value) ?? 0))
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Actions Row
    
    private var actionsRow: some View {
        HStack(spacing: 10) {
            actionCard(icon: "bolt.fill", title: "Power Actions", color: .primary) {
                showPowerActionsSheet = true
                AnalyticsManager.shared.trackPowerActionsTap()
            }
            actionCard(icon: "wind", title: "Breathe", color: .green) {
                showMeditate = true
                AnalyticsManager.shared.trackBreatheTap()
            }
            actionCard(icon: "flame.fill", title: "Roast Me", color: .orange) {
                showRoastMe = true
                AnalyticsManager.shared.trackRoastMeTap()
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func actionCard(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            Haptics.feedback(style: .light)
            action()
        }) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 16)
            .background(cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Weekly Card
    
    private var weeklyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("This Week")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                
                Spacer()
                
                if trackingStore.hasCheckedInToday {
                    Text("✓ checked in")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.green)
                }
            }
            
            HStack(spacing: 0) {
                ForEach(0..<weekDays.count, id: \.self) { index in
                    VStack(spacing: 8) {
                        Text(weekDays[index])
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        weekDayCircle(status: trackingStore.weekStatuses[index], checkIn: trackingStore.weeklyCheckIns[index])
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(18)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func weekDayCircle(status: Int, checkIn: DailyCheckIn?) -> some View {
        let size: CGFloat = 32
        
        ZStack {
            if let checkIn = checkIn {
                Circle()
                    .fill(status == 1 ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                    .frame(width: size, height: size)
                
                Text(moodEmoji(checkIn.mood))
                    .font(.system(size: 14))
            } else {
                switch status {
                case 1:
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: size, height: size)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.green)
                        )
                case 2:
                    Circle()
                        .fill(Color.red.opacity(0.15))
                        .frame(width: size, height: size)
                        .overlay(
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.red)
                        )
                default:
                    Circle()
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1.5)
                        .frame(width: size, height: size)
                }
            }
        }
    }
    
    // MARK: - Level Progress Card
    
    private var levelProgressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(trackingStore.currentLevel.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))

                    HStack(spacing: 6) {
                        Text("Level \(trackingStore.currentLevel.index) • \(trackingStore.daysLeftInLevel)d to next")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        if trackingStore.bonusDays > 0 {
                            Text("+\(String(format: "%.0f", trackingStore.bonusDays))d")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(hex: "34C759"))
                        }
                    }
                }

                Spacer()

                Text("\(Int(trackingStore.levelProgress * 100))%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: trackingStore.currentLevel.color))
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 8)

                    Capsule()
                        .fill(Color(hex: trackingStore.currentLevel.color))
                        .frame(width: geometry.size.width * CGFloat(trackingStore.levelProgress), height: 8)
                        .animation(.spring(response: 0.5), value: trackingStore.levelProgress)
                }
            }
            .frame(height: 8)
        }
        .padding(18)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
    }
    
    // MARK: - Check-In Prompt Card
    
    private var checkInPromptCard: some View {
        Button {
            showCheckInSheet = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "pencil.line")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Check-In")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text("How are you feeling today?")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal, 16)
    }
    
    // MARK: - Quote Card
    
    private var quoteCard: some View {
        Text(stickyQuote)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .padding(.vertical, 8)
    }
    
    // MARK: - Panic Button
    
    private var panicButtonView: some View {
        Button {
            showPanic = true
            Haptics.feedback(style: .heavy)
            // Track panic button tap for power user identification
            AnalyticsManager.shared.trackPanicButtonTap()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 18, weight: .bold))
                Text("PANIC BUTTON")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .tracking(0.5)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.red)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(creamBg)
    }
    
    // MARK: - Helpers
    
    private func moodEmoji(_ value: Int) -> String {
        switch value {
        case 1: return "😢"
        case 2: return "😔"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }
    
    @ViewBuilder
    func streakCircle(status: Int) -> some View {
        let size: CGFloat = 36
        
        switch status {
        case 1:
            Circle()
                .fill(Color.green.opacity(0.2))
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                )
        case 2:
            Circle()
                .fill(Color.red.opacity(0.1))
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: "xmark")
                        .font(.caption.bold())
                        .foregroundColor(.red)
                )
        default:
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: size, height: size)
        }
    }
    
    private var streakMotivationText: String {
        let successDays = trackingStore.state.successfulDaysThisWeek
        let relapseDays = trackingStore.state.relapsesDaysThisWeek
        
        if relapseDays == 0 && successDays > 0 {
            return "Perfect week so far! Keep it green! 🌿"
        } else if relapseDays > 0 {
            return "You slipped, but you're still here. That's growth 💪"
        } else {
            return "New week, fresh start. Let's make it count! 🔥"
        }
    }
    
    func updateTimer() {
        let startDate = trackingStore.state.noContactStartDate
        let diff = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: startDate, to: Date())
        
        let days = String(trackingStore.totalHealingDays)
        let hours = String(format: "%02d", diff.hour ?? 0)
        let minutes = String(format: "%02d", diff.minute ?? 0)
        let seconds = String(format: "%02d", diff.second ?? 0)
        
        timeComponents = (days, hours, minutes, seconds)
    }
}

struct QuickCheckInSheet: View {
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(NotificationStore.self) private var notificationStore
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var mood: Int = 3
    @State private var urge: Int = 5
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Daily Check-In")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.primary.opacity(0.5))
                        .frame(width: 32, height: 32)
                        .background(Color(hex: "FFFDF9"))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    VStack(spacing: 24) {
                        VStack(spacing: 14) {
                            Text("How's your mood?")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            
                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { i in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            mood = i
                                        }
                                    } label: {
                                        Text(moodEmoji(i))
                                            .font(.system(size: i == mood ? 44 : 28))
                                            .opacity(i == mood ? 1 : 0.4)
                                            .scaleEffect(i == mood ? 1.1 : 1)
                                    }
                                }
                            }
                            
                            Text(moodLabel(mood))
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        
                        Rectangle()
                            .fill(Color.primary.opacity(0.06))
                            .frame(height: 1)
                        
                        VStack(spacing: 14) {
                            Text("Urge to contact them?")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            
                            VStack(spacing: 10) {
                                Slider(value: Binding(
                                    get: { Double(urge) },
                                    set: { urge = Int($0) }
                                ), in: 0...10, step: 1)
                                .tint(urgeSliderColor)
                                
                                HStack {
                                    Text("0")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("\(urge)")
                                        .font(.system(size: 28, weight: .black, design: .rounded))
                                        .foregroundStyle(urgeSliderColor)
                                    Spacer()
                                    Text("10")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Text(urgeLabel(urge))
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(20)
                    .background(Color(hex: "FFFDF9"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 16)
                    
                    Button {
                        TrackingPersistence.recordDailyCheckIn(store: trackingStore, context: modelContext, mood: mood, urge: urge)
                        dismiss()
                    } label: {
                        Text("Save Check-In")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color(hex: "F5F0E8").ignoresSafeArea())
        .onAppear {
            if let existing = trackingStore.todayCheckIn {
                mood = existing.mood
                urge = existing.urge
            }
        }
    }
    
    private func moodEmoji(_ value: Int) -> String {
        switch value {
        case 1: return "😢"
        case 2: return "😔"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }
    
    private func moodLabel(_ value: Int) -> String {
        switch value {
        case 1: return "Struggling today"
        case 2: return "Not great, but surviving"
        case 3: return "Okay, getting by"
        case 4: return "Pretty good actually"
        case 5: return "Feeling great!"
        default: return ""
        }
    }
    
    private func urgeLabel(_ value: Int) -> String {
        switch value {
        case 0...2: return "You're in control 💪"
        case 3...5: return "Stay strong, you got this"
        case 6...8: return "The urge is real, but so is your strength"
        default: return "High alert—use the panic button if needed!"
        }
    }
    
    private var urgeSliderColor: Color {
        switch urge {
        case 0...3: return .green
        case 4...6: return .orange
        default: return .red
        }
    }
}

struct PowerActionsSheet: View {
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var completedAction: PowerActionType?
    @State private var selectedAction: PowerActionType?
    @State private var showConfirmation = false
    @State private var appear = false
    
    private var lifetimeStats: (actions: Int, days: Double) {
        (trackingStore.powerActions.count, trackingStore.lifetimeBonusDays)
    }
    
    private var currentBonusDays: Double {
        trackingStore.bonusDays
    }
    
    private var maxBonusDays: Int {
        4
    }
    
    private var hasReachedMax: Bool {
        currentBonusDays >= Double(maxBonusDays)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Power Actions")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                    Text("Each action can only be done once")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.primary.opacity(0.5))
                        .frame(width: 36, height: 36)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if lifetimeStats.actions > 0 {
                            lifetimeStatsCard
                                .opacity(appear ? 1 : 0)
                                .offset(y: appear ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: appear)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("POWER MOVES")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .tracking(2)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                Text("Total: 4 days")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color(hex: "34C759"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color(hex: "34C759").opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            .padding(.horizontal, 24)
                            
                            ForEach(Array(PowerActionType.allActions.enumerated()), id: \.element) { index, action in
                                let isCompleted = trackingStore.powerActions.contains(where: { $0.type == action })
                                
                                PowerActionRow(action: action, isCompleted: isCompleted) {
                                    if !isCompleted {
                                        Haptics.feedback(style: .medium)
                                        selectedAction = action
                                    }
                                }
                                .disabled(isCompleted)
                                .opacity(appear ? 1 : 0)
                                .offset(y: appear ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.06), value: appear)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        if !trackingStore.powerActions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("YOUR WINS")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .tracking(2)
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("\(trackingStore.powerActions.count) completed")
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 24)
                                
                                VStack(spacing: 0) {
                                    ForEach(Array(trackingStore.powerActions.sorted(by: { $0.date > $1.date }).prefix(5).enumerated()), id: \.element.id) { index, action in
                                        HStack(spacing: 14) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(hex: "34C759").opacity(0.12))
                                                    .frame(width: 42, height: 42)
                                                
                                                Image(systemName: action.type.icon)
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundStyle(Color(hex: "34C759"))
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(action.type.displayName)
                                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                Text(action.date.formatted(date: .abbreviated, time: .omitted))
                                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                                    .foregroundStyle(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Text("+\(String(format: "%.1f", action.type.bonusDays))d")
                                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                                .foregroundStyle(Color(hex: "34C759"))
                                        }
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 20)
                                        
                                        if index < min(trackingStore.powerActions.count - 1, 4) {
                                            Divider()
                                                .padding(.leading, 76)
                                        }
                                    }
                                }
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
                                .padding(.horizontal, 20)
                            }
                            .opacity(appear ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: appear)
                        }
                        
                        Color.clear.frame(height: 20)
                    }
                    .padding(.top, 8)
                }
                .disabled(completedAction != nil)
                
                if let action = completedAction {
                    successOverlay(for: action)
                }
            }
        }
        .background(Color(hex: "F9F9F9").ignoresSafeArea())
        .onAppear { appear = true }
        .sheet(item: $selectedAction) { action in
            PowerActionSignSheet(action: action) {
                handleCompletion(action: action)
                selectedAction = nil
            }
        }
    }
    
    private var lifetimeStatsCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("\(lifetimeStats.actions)")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                    Text("completed")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Rectangle()
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 1, height: 36)
                
                VStack(spacing: 4) {
                    HStack(spacing: 2) {
                        Text("+\(String(format: "%.0f", currentBonusDays))")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(hasReachedMax ? Color(hex: "34C759") : .primary)
                        Text("/\(maxBonusDays)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    Text("bonus days")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Rectangle()
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 1, height: 36)
                
                VStack(spacing: 4) {
                    Text("+\(String(format: "%.0f", lifetimeStats.days))")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "FF9500"))
                    Text("lifetime")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            
            if hasReachedMax {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                    Text("Max bonus reached for this level!")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(Color(hex: "34C759"))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(hex: "34C759").opacity(0.1))
                .clipShape(Capsule())
            } else {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.primary.opacity(0.08))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(Color(hex: "34C759"))
                            .frame(width: geo.size.width * (currentBonusDays / Double(maxBonusDays)), height: 6)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func successOverlay(for action: PowerActionType) -> some View {
        Color.black.opacity(0.6)
            .ignoresSafeArea()
            .transition(.opacity)
        
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(Color(hex: "34C759").opacity(0.2))
                    .frame(width: 140, height: 140)
                
                Circle()
                    .fill(Color(hex: "34C759"))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 44, weight: .black))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 10) {
                Text("CLAIMED 🔥")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.7))
                
                Text("You chose yourself.")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("That's main character energy right there.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: 12) {
                VStack(spacing: 2) {
                    Text("+\(String(format: "%.1f", action.bonusDays))")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                    Text("days earned")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .opacity(0.8)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color(hex: "34C759"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(48)
        .transition(.scale(scale: 0.85).combined(with: .opacity))
        .zIndex(1)
    }
    
    func handleCompletion(action: PowerActionType) {
        TrackingPersistence.recordPowerAction(store: trackingStore, context: modelContext, type: action)
        Haptics.notification(type: .success)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            completedAction = action
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            dismiss()
        }
    }
}

struct PowerActionSignSheet: View {
    let action: PowerActionType
    let onSign: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var signatureLines: [Line] = []
    @State private var currentLine = Line(points: [])
    @State private var showContent = false
    @State private var isSigning = false
    
    private var hasSignature: Bool {
        let totalPoints = signatureLines.reduce(0) { $0 + $1.points.count }
        return totalPoints > 15
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.primary.opacity(0.5))
                        .frame(width: 36, height: 36)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "5856D6").opacity(0.12))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: action.icon)
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(Color(hex: "5856D6"))
                        }
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.8)
                        
                        VStack(spacing: 12) {
                            HStack(spacing: 6) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                Text("ONE-TIME ACTION")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .tracking(1.5)
                            }
                            .foregroundStyle(Color(hex: "5856D6"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color(hex: "5856D6").opacity(0.12))
                            .clipShape(Capsule())
                            
                            Text(action.displayName)
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .multilineTextAlignment(.center)
                            
                            Text(action.description)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .padding(.horizontal, 24)
                        
                        VStack(spacing: 4) {
                            Text("+\(String(format: "%.1f", action.bonusDays))")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundStyle(Color(hex: "34C759"))
                            Text("bonus days")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color(hex: "34C759").opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 24)
                        .opacity(showContent ? 1 : 0)
                        
                        VStack(spacing: 12) {
                            Text("SIGN TO CONFIRM")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .tracking(2)
                                .foregroundColor(.secondary)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.06), radius: 16, y: 6)
                                
                                if signatureLines.isEmpty && currentLine.points.isEmpty {
                                    VStack(spacing: 6) {
                                        Image(systemName: "signature")
                                            .font(.system(size: 24))
                                            .foregroundColor(.black.opacity(0.15))
                                        Text("Draw your signature")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.black.opacity(0.2))
                                    }
                                }
                                
                                Canvas { context, _ in
                                    for line in signatureLines {
                                        var path = Path()
                                        path.addLines(line.points)
                                        context.stroke(path, with: .color(.black), lineWidth: 2.5)
                                    }
                                    var currentPath = Path()
                                    currentPath.addLines(currentLine.points)
                                    context.stroke(currentPath, with: .color(.black), lineWidth: 2.5)
                                }
                                .gesture(
                                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                        .onChanged { value in
                                            currentLine.points.append(value.location)
                                        }
                                        .onEnded { _ in
                                            signatureLines.append(currentLine)
                                            currentLine = Line(points: [])
                                        }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            .frame(height: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(hasSignature ? Color(hex: "34C759") : Color.black.opacity(0.06), lineWidth: hasSignature ? 2 : 1)
                                    .animation(.easeInOut(duration: 0.2), value: hasSignature)
                            )
                            .padding(.horizontal, 24)
                            
                            if !signatureLines.isEmpty {
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        signatureLines = []
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.system(size: 12, weight: .semibold))
                                        Text("Clear")
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                    }
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.95)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                }
            }
            
            VStack(spacing: 8) {
                Button {
                    if hasSignature {
                        Haptics.feedback(style: .heavy)
                        isSigning = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSign()
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isSigning {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("I Did This")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(hasSignature ? Color.black : Color.black.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(hasSignature ? 0.15 : 0), radius: 12, y: 6)
                }
                .disabled(!hasSignature || isSigning)
                .animation(.easeInOut(duration: 0.2), value: hasSignature)
                
                Text("You can only claim each action once—make it count!")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
            .background(Color(hex: "F9F9F9"))
        }
        .background(Color(hex: "F9F9F9").ignoresSafeArea())
        .presentationCornerRadius(28)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showContent = true
            }
        }
    }
}

struct PowerActionRow: View {
    let action: PowerActionType
    let isCompleted: Bool
    let onComplete: () -> Void
    
    var body: some View {
        Button {
            onComplete()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isCompleted ? Color(hex: "34C759").opacity(0.12) : Color(hex: "5856D6").opacity(0.08))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: isCompleted ? "checkmark" : action.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isCompleted ? Color(hex: "34C759") : Color(hex: "5856D6"))
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(action.displayName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(isCompleted ? .secondary : .primary)
                        .strikethrough(isCompleted, color: .secondary)
                    
                    Text(action.description)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color(hex: "34C759"))
                } else {
                    Text("+\(String(format: "%.1f", action.bonusDays))d")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(hex: "5856D6"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(isCompleted ? 0.02 : 0.06), radius: 12, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(isCompleted ? Color(hex: "34C759").opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PowerActionButtonStyle())
        .disabled(isCompleted)
    }
}

struct PowerActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
                .environment(TrackingStore.previewNewUser)
                .environment(NotificationStore())
                .environment(previewUserProfile())
                .previewDisplayName("New User")
            
            HomeView()
                .environment(TrackingStore.previewLevel2WithProgress)
                .environment(NotificationStore())
                .environment(previewUserProfile())
                .previewDisplayName("Level 2 - With Progress")
        }
    }
    
    static func previewUserProfile() -> UserProfileStore {
        let store = UserProfileStore()
        store.profile = UserProfile(
            name: "Sarah",
            gender: "Female",
            exName: "Jake",
            exGender: "Male",
            relationshipDuration: "1 - 3 years",
            breakupInitiator: "They did (Their loss)",
            contactStatus: "No Contact (Clean streak)",
            socialMediaHabits: "Muted but looking",
            sleepQuality: "Tossing & turning",
            mood: "Okay-ish 😐",
            excitementRating: 4,
            onboardingCompletedDate: Date(),
            notificationPreferences: .defaults
        )
        return store
    }
}
