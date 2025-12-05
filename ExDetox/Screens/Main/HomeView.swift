import SwiftUI
import Combine
import SwiftData

struct HomeView: View {
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(NotificationStore.self) private var notificationStore
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(\.modelContext) private var modelContext
    
    let weekDays = ["M", "T", "W", "T", "F", "S", "S"]
    
    // Timer state
    @State private var timeComponents: (days: String, hours: String, minutes: String, seconds: String) = ("00", "00", "00", "00")
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Sheets state
    @State private var showSettings = false
    @State private var showRoastMe = false
    @State private var showMeditate = false
    @State private var showPanic = false
    @State private var showRelapseConfirm = false
    @State private var showCheckInSheet = false
    @State private var showPowerActionsSheet = false
    
    @State private var whyItems: [WhyItem] = [
        WhyItem(title: "He never listened to me when I was crying."),
        WhyItem(title: "Forgot my birthday... again.", imageName: "photo"),
        WhyItem(title: "Gaslighting 101.")
    ]
    
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
            
            ScrollView {
                VStack(spacing: 20) {
                    // 2. Timer (The "Streak")
                    timerCard
                    
                    // 1. Weekly Streak
                    weeklyStreakCard
                    
                    // 3. Level (Separate)
                    levelCard
                    
                    // 4. Simplified Check-in
                    simpleCheckInCard
                    
                    // 5. Other Actions
                    simpleActionsView
                    
                    // 6. Quote (Minimal)
                    if !randomQuote.isEmpty {
                        Text(randomQuote)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 10)
                    }
                    
                    // 7. Relapse Button (Subtle)
                    Button {
                        showRelapseConfirm = true
                    } label: {
                        Text("I broke no-contact")
                            .font(.caption)
                            .foregroundStyle(.red.opacity(0.8))
                            .padding(.top, 20)
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 20)
            }
            
            panicButtonView
        }
        .background(Color(hex: "F9F9F9").ignoresSafeArea())
        .onReceive(timer) { _ in
            updateTimer()
        }
        .onAppear {
            trackingStore.updateForCurrentDate()
            updateTimer()
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
            PanicView(whyItems: $whyItems)
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
    
    private var headerView: some View {
        HStack {
            Text("Hey, \(userName) 👋")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.black)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
        }
        .frame(height: 62)
        .padding(.horizontal, 20)
        .background(Color(hex: "F9F9F9"))
    }
    
    private var timerCard: some View {
        VStack(spacing: 8) {
            Text(timeComponents.days)
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .contentTransition(.numericText(value: Double(timeComponents.days) ?? 0))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(height: 80)
            
            Text("DAYS SINCE THE ICK")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .tracking(1)
            
            HStack(spacing: 12) {
                timeUnit(value: timeComponents.hours, unit: "h")
                timeUnit(value: timeComponents.minutes, unit: "m")
                timeUnit(value: timeComponents.seconds, unit: "s")
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
    }
    
    private var levelCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("CURRENT LEVEL")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("Level \(trackingStore.currentLevel.index)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: trackingStore.currentLevel.color))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: trackingStore.currentLevel.color).opacity(0.1))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 4)
            
            HStack(spacing: 16) {
                Text(trackingStore.currentLevel.emoji)
                    .font(.title)
                    .padding(12)
                    .background(Color(hex: trackingStore.currentLevel.color).opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(trackingStore.currentLevel.title)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("\(Int(trackingStore.levelProgress * 100))%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 6)
                            
                            Capsule()
                                .fill(Color(hex: trackingStore.currentLevel.color))
                                .frame(width: geometry.size.width * CGFloat(trackingStore.levelProgress), height: 6)
                        }
                    }
                    .frame(height: 6)
                    
                    if trackingStore.daysLeftInLevel > 0 {
                        Text("\(trackingStore.daysLeftInLevel) days to next level")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 20)
    }
    
    // Kept for backward compatibility if needed, but not used in body
    private var heroStatusCard: some View {
        EmptyView()
    }
    
    private var weeklyStreakCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("THIS WEEK")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text("\(trackingStore.currentStreakDays)d streak")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 16) {
                HStack(spacing: 0) {
                    ForEach(0..<weekDays.count, id: \.self) { index in
                        VStack(spacing: 12) {
                            Text(weekDays[index])
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            streakCircle(status: trackingStore.weekStatuses[index])
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 20)
    }
    
    private var simpleCheckInCard: some View {
        Group {
            if trackingStore.hasCheckedInToday {
                weeklyMoodTrackerCard
            } else {
                Button {
                    showCheckInSheet = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Check-In")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Track your mood & urges")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("Log Now")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                    .padding(20)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    private var weeklyMoodTrackerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("WEEKLY MOOD")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    showCheckInSheet = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue.opacity(0.8))
                }
            }
            .padding(.horizontal, 4)
            
            HStack(spacing: 0) {
                ForEach(0..<weekDays.count, id: \.self) { index in
                    VStack(spacing: 12) {
                        Text(weekDays[index])
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        if let checkIn = trackingStore.weeklyCheckIns[index] {
                            Text(moodEmoji(checkIn.mood))
                                .font(.title3)
                                .frame(width: 32, height: 32)
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 32, height: 32)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 20)
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
    
    private var panicButtonView: some View {
        Button {
            showPanic = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                Text("PANIC BUTTON")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.red)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(hex: "F9F9F9"))
    }
    
    private var simpleActionsView: some View {
        HStack(spacing: 12) {
            // Power Actions
            simpleActionButton(title: "Power Actions", icon: "bolt.fill", color: .purple) {
                showPowerActionsSheet = true
            }
            
            // Meditate
            simpleActionButton(title: "Meditate", icon: "wind", color: .teal) {
                showMeditate = true
            }
            
            // Roast Me
            simpleActionButton(title: "Roast Me", icon: "flame.fill", color: .orange) {
                showRoastMe = true
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func simpleActionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    @ViewBuilder
    func timeUnit(value: String, unit: String) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) {
            Text(value)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .contentTransition(.numericText(value: Double(value) ?? 0))
            
            Text(unit)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
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
                .shadow(color: .green.opacity(0.1), radius: 2, x: 0, y: 2)
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
        let days = String(diff.day ?? 0)
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
            // Header
            HStack {
                Text("Daily Check-In")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 20)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Main Card
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            Text("How's your mood?")
                                .font(.headline)
                            
                            HStack(spacing: 16) {
                                ForEach(1...5, id: \.self) { i in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            mood = i
                                        }
                                    } label: {
                                        Text(moodEmoji(i))
                                            .font(.system(size: i == mood ? 48 : 32))
                                            .opacity(i == mood ? 1 : 0.5)
                                            .scaleEffect(i == mood ? 1.1 : 1)
                                    }
                                }
                            }
                            
                            Text(moodLabel(mood))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Divider()
                        
                        VStack(spacing: 12) {
                            Text("Urge to contact them?")
                                .font(.headline)
                            
                            VStack(spacing: 8) {
                                Slider(value: Binding(
                                    get: { Double(urge) },
                                    set: { urge = Int($0) }
                                ), in: 0...10, step: 1)
                                .tint(urgeSliderColor)
                                
                                HStack {
                                    Text("0")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("\(urge)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(urgeSliderColor)
                                    Spacer()
                                    Text("10")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Text(urgeLabel(urge))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    
                    Button {
                        TrackingPersistence.recordDailyCheckIn(store: trackingStore, context: modelContext, mood: mood, urge: urge)
                        dismiss()
                    } label: {
                        Text("Save Check-In")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color(hex: "F9F9F9").ignoresSafeArea())
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Speed Up Your Healing")
                            .font(.headline)
                        Text("Complete these actions to earn bonus days and level up faster. Each action you take proves you're moving forward.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        ForEach(trackingStore.currentLevel.challenges, id: \.self) { action in
                            PowerActionRow(action: action) {
                                TrackingPersistence.recordPowerAction(store: trackingStore, context: modelContext, type: action)
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    if !trackingStore.powerActions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Completed Actions")
                                .font(.headline)
                                .padding(.horizontal, 20)
                            
                            ForEach(trackingStore.powerActions.prefix(5)) { action in
                                HStack(spacing: 12) {
                                    Image(systemName: action.type.icon)
                                        .foregroundStyle(.green)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(action.type.displayName)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(action.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("+\(String(format: "%.1f", action.type.bonusDays))d")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.green)
                                }
                                .padding(12)
                                .background(Color.green.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            .navigationTitle("Power Actions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PowerActionRow: View {
    let action: PowerActionType
    let onComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: action.icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.purple)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(action.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(action.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button {
                onComplete()
            } label: {
                Text("+\(String(format: "%.1f", action.bonusDays))d")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.purple)
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
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
