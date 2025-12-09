import SwiftUI
import Combine
import SwiftData

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
    
    private var dailyQuotes: [String] {
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
            }
            actionCard(icon: "wind", title: "Breathe", color: .green) {
                showMeditate = true
            }
            actionCard(icon: "flame.fill", title: "Roast Me", color: .orange) {
                showRoastMe = true
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
                    
                    Text("Level \(trackingStore.currentLevel.index) • \(trackingStore.daysLeftInLevel)d to next")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
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
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Power Actions")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                    Text("Level up your healing")
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
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            ForEach(Array(trackingStore.currentLevel.challenges.enumerated()), id: \.element) { index, action in
                                let isCompleted = !action.isRepeatable && trackingStore.powerActions.contains(where: { $0.type == action })
                                
                                PowerActionRow(action: action, isCompleted: isCompleted) {
                                    if !isCompleted {
                                        Haptics.feedback(style: .medium)
                                        selectedAction = action
                                    }
                                }
                                .disabled(isCompleted)
                                .opacity(appear ? 1 : 0)
                                .offset(y: appear ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.08), value: appear)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        if !trackingStore.powerActions.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("COMPLETED")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .tracking(2)
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
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
    
    @ViewBuilder
    private func successOverlay(for action: PowerActionType) -> some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()
            .transition(.opacity)
        
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color(hex: "34C759").opacity(0.15))
                    .frame(width: 120, height: 120)
                
                Text("✓")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "34C759"))
            }
            
            VStack(spacing: 8) {
                Text("You did it.")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("You chose yourself today.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }
            
            Text("+\(String(format: "%.1f", action.bonusDays)) days")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color(hex: "34C759"))
                .clipShape(Capsule())
        }
        .padding(48)
        .transition(.scale(scale: 0.9).combined(with: .opacity))
        .zIndex(1)
    }
    
    func handleCompletion(action: PowerActionType) {
        TrackingPersistence.recordPowerAction(store: trackingStore, context: modelContext, type: action)
        Haptics.notification(type: .success)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            completedAction = action
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 28) {
                    VStack(spacing: 12) {
                        Text("COMMITMENT")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .tracking(3)
                            .foregroundColor(.secondary)
                        
                        Text("Sign to confirm.")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    
                    VStack(spacing: 8) {
                        Text("I confirm that I have completed:")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        Text(action.displayName)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                        Text("By signing, I choose my healing.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                    .opacity(showContent ? 1 : 0)
                    .padding(.horizontal, 24)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.06), radius: 16, y: 6)
                        
                        if signatureLines.isEmpty && currentLine.points.isEmpty {
                            Text("Sign here")
                                .font(.system(size: 28, weight: .light, design: .serif))
                                .italic()
                                .foregroundColor(.black.opacity(0.1))
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
                    .frame(height: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.95)
                }
                
                Spacer()
                Spacer()
                
                VStack(spacing: 12) {
                    Button {
                        if hasSignature {
                            Haptics.feedback(style: .heavy)
                            isSigning = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onSign()
                            }
                        }
                    } label: {
                        Text("Confirm")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(hasSignature ? Color.black : Color.black.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(hasSignature ? 0.15 : 0), radius: 12, y: 6)
                    }
                    .disabled(!hasSignature || isSigning)
                    .animation(.easeInOut(duration: 0.2), value: hasSignature)
                    
                    if !signatureLines.isEmpty {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                signatureLines = []
                            }
                        } label: {
                            Text("Clear signature")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
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
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isCompleted ? Color(hex: "34C759").opacity(0.12) : Color.black.opacity(0.06))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: isCompleted ? "checkmark" : action.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isCompleted ? Color(hex: "34C759") : .primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(action.displayName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(isCompleted ? .secondary : .primary)
                        .strikethrough(isCompleted, color: .secondary)
                        .multilineTextAlignment(.leading)
                    
                    Text(action.description)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if !isCompleted {
                    Text("+\(String(format: "%.1f", action.bonusDays))d")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .clipShape(Capsule())
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
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
            onboardingCompletedDate: Date()
        )
        return store
    }
}
