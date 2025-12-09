import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(NotificationStore.self) private var notificationStore
    @Environment(\.modelContext) private var modelContext
    
    @State private var animateProgress = false
    @State private var showAllLevels = false
    @State private var showBadgesSheet = false
    @State private var showPowerActionsSheet = false
    @State private var showSettings = false
    
    private let creamBg = Color(hex: "F5F0E8")
    private let cardBg = Color(hex: "FFFDF9")

    var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    mainContent
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .background(creamBg.ignoresSafeArea())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateProgress = true
            }
        }
        .sheet(isPresented: $showAllLevels) {
            AllLevelsSheet()
        }
        .sheet(isPresented: $showBadgesSheet) {
            BadgesSheet()
        }
        .sheet(isPresented: $showPowerActionsSheet) {
            PowerActionsSheet()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    private var headerView: some View {
        HStack(alignment: .center) {
            Text("Analytics")
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
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private var mainContent: some View {
        levelProgressCard
        freedomCountdownCard
        weeklyMoodCard
        statsGrid
        powerActionsSummaryCard
        badgesPreviewCard
    }

    @ViewBuilder
    private var levelProgressCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                Text(trackingStore.currentLevel.emoji)
                    .font(.system(size: 36))
                    .frame(width: 56, height: 56)
                    .background(Color(hex: trackingStore.currentLevel.color).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(trackingStore.currentLevel.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    
                    Text("Level \(trackingStore.currentLevel.index)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if trackingStore.daysLeftInLevel <= 0 {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                }
            }
            
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.primary.opacity(0.08))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(Color(hex: trackingStore.currentLevel.color))
                            .frame(width: animateProgress ? geometry.size.width * CGFloat(trackingStore.levelProgress) : 0, height: 8)
                            .animation(.spring(response: 1, dampingFraction: 0.8), value: animateProgress)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text("\(Int(trackingStore.levelProgress * 100))%")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: trackingStore.currentLevel.color))
                    
                    Spacer()
                    
                    if trackingStore.daysLeftInLevel > 0 {
                        Text("\(trackingStore.daysLeftInLevel)d to level up")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Completed! 🏆")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                    }
                }
            }

            if let nextLevel = trackingStore.currentLevel.nextLevel {
                HStack(spacing: 12) {
                    Text(nextLevel.emoji)
                        .font(.system(size: 24))
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Next: \(nextLevel.title)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Level \(nextLevel.index)")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    Spacer()

                    Button {
                        showAllLevels = true
                        Haptics.feedback(style: .light)
                    } label: {
                        Text("See all")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
                .padding(14)
                .background(Color(hex: nextLevel.color))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(18)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
    }

    private var freedomCountdownCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 6)
                    .fill(Color.primary.opacity(0.08))
                
                Circle()
                    .trim(from: 0.0, to: animateProgress ? CGFloat(trackingStore.detoxProgress) : 0.0)
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(Color.green)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.spring(response: 1.5, dampingFraction: 0.7), value: animateProgress)
                
                Text("\(Int(trackingStore.detoxProgress * 100))%")
                    .font(.system(size: 14, weight: .black, design: .rounded))
            }
            .frame(width: 56, height: 56)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Freedom Countdown")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                
                Text("\(trackingStore.daysLeftInProgram) days left")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                
                Text("Until \(trackingStore.freedomDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(18)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var weeklyMoodCard: some View {
        if !trackingStore.dailyCheckIns.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Text("Weekly Mood")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Avg Mood")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                        HStack(spacing: 2) {
                            Text(String(format: "%.1f", trackingStore.state.averageMoodThisWeek))
                                .font(.system(size: 22, weight: .black, design: .rounded))
                            Text("/5")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Avg Urge")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                        HStack(spacing: 2) {
                            Text(String(format: "%.1f", trackingStore.state.averageUrgeThisWeek))
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundStyle(urgeColor(Int(trackingStore.state.averageUrgeThisWeek)))
                            Text("/10")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Check-Ins")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text("\(trackingStore.dailyCheckIns.count)")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(18)
            .background(cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 16)
        }
    }
    
    private func urgeColor(_ value: Int) -> Color {
        switch value {
        case 0...3: return .green
        case 4...6: return .orange
        default: return .red
        }
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard(title: "Current Streak", value: "\(trackingStore.currentStreakDays)", unit: "days", icon: "flame.fill", color: .orange)
            statCard(title: "Max Streak", value: "\(trackingStore.maxStreak)", unit: "days", icon: "trophy.fill", color: .yellow)
            statCard(title: "Relapses", value: "\(trackingStore.relapses)", unit: "times", icon: "arrow.counterclockwise", color: .red)
            statCard(
                title: "Start Date",
                value: trackingStore.state.programStartDate.formatted(.dateTime.day().month()),
                unit: String(trackingStore.state.programStartDate.formatted(.dateTime.year())),
                icon: "calendar",
                color: .blue
            )
        }
        .padding(.horizontal, 16)
    }

    private var powerActionsSummaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Power Action Days")
                .font(.system(size: 16, weight: .bold, design: .rounded))

            let days = trackingStore.bonusDays

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(String(format: "%.1f", days))
                    .font(.system(size: 40, weight: .black, design: .rounded))
                Text("days faster")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Text("Brave actions accelerate your healing.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)

            Button {
                showPowerActionsSheet = true
                Haptics.feedback(style: .light)
            } label: {
                HStack {
                    Text("Do a power action")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(18)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
    }

    private var badgesPreviewCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Your Badges")
                    .font(.system(size: 16, weight: .bold, design: .rounded))

                Spacer()

                Text("\(trackingStore.badges.count)/\(BadgeType.allCases.count)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            let allTypes = BadgeType.allCases
            let earnedTypes = Set(trackingStore.badges.map(\.type))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(allTypes.prefix(6), id: \.self) { badgeType in
                    let earned = earnedTypes.contains(badgeType)

                    VStack(spacing: 6) {
                        Image(systemName: badgeType.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(earned ? Color(hex: badgeType.color) : .gray.opacity(0.3))
                            .frame(width: 42, height: 42)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(earned ? Color(hex: badgeType.color).opacity(0.12) : Color.primary.opacity(0.04))
                            )

                        Text(badgeType.title)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(earned ? .primary : .secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .opacity(earned ? 1 : 0.5)
                }
            }

            Button {
                showBadgesSheet = true
                Haptics.feedback(style: .light)
            } label: {
                Text("See all badges")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(18)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    func statCard(title: String, value: String, unit: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
                Text(unit)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct AllLevelsSheet: View {
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("All Levels")
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
                VStack(spacing: 12) {
                    ForEach(HealingLevel.allCases, id: \.self) { level in
                        LevelDetailRow(level: level, currentLevel: trackingStore.currentLevel)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .background(Color(hex: "F5F0E8").ignoresSafeArea())
    }
}

struct LevelDetailRow: View {
    let level: HealingLevel
    let currentLevel: HealingLevel
    
    var isUnlocked: Bool {
        level.rawValue <= currentLevel.rawValue
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(level.emoji)
                    .font(.system(size: 28))
                    .frame(width: 48, height: 48)
                    .background(Color(hex: level.color).opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .grayscale(isUnlocked ? 0 : 1)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(isUnlocked ? .primary : .secondary)
                    
                    Text("Level \(level.index)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary.opacity(0.5))
                } else if level == currentLevel {
                     Text("Current")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.green)
                        .clipShape(Capsule())
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.green)
                }
            }
            
            Text(level.subtitle)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
            
            if !isUnlocked {
                HStack(spacing: 5) {
                    Image(systemName: "lock")
                        .font(.system(size: 10))
                    Text("Unlocks after \(level.minDays) days")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color(hex: "FFFDF9"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(isUnlocked ? 1 : 0.7)
    }
}

struct BadgesSheet: View {
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("All Badges")
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
                VStack(spacing: 12) {
                    ForEach(BadgeType.allCases, id: \.self) { badgeType in
                        BadgeDetailRow(
                            badgeType: badgeType,
                            isEarned: trackingStore.badges.contains(where: { $0.type == badgeType }),
                            progressText: progressText(for: badgeType)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .background(Color(hex: "F5F0E8").ignoresSafeArea())
    }

    private func progressText(for badge: BadgeType) -> String {
        let streak = trackingStore.currentStreakDays
        switch badge {
        case .firstDay:
            return "\(min(streak, 1))/1 day"
        case .weekStreak:
            return "\(min(streak, 7))/7 days"
        case .twoWeekStreak:
            return "\(min(streak, 14))/14 days"
        case .monthStreak:
            return "\(min(streak, 30))/30 days"
        case .deletedFolder:
            let done = trackingStore.powerActions.contains(where: { $0.type == .deletePhotos })
            return done ? "Done" : "Not yet"
        case .blockedEx:
            let done = trackingStore.powerActions.contains(where: { $0.type == .block })
            return done ? "Done" : "Not yet"
        case .unfollowedAll:
            let done = trackingStore.powerActions.contains(where: { $0.type == .unfollow })
            return done ? "Done" : "Not yet"
        case .firstJournal:
            let done = trackingStore.powerActions.contains(where: { $0.type == .realityJournaling })
            return done ? "Done" : "Not yet"
        case .newExperience:
            let done = trackingStore.powerActions.contains(where: { $0.type == .newExperience })
            return done ? "Done" : "Not yet"
        case .glowUpReached:
            let done = trackingStore.currentLevel.rawValue >= HealingLevel.glowUp.rawValue
            return done ? "Reached" : "Not yet"
        case .unbotheredReached:
            let done = trackingStore.currentLevel == .unbothered
            return done ? "Reached" : "Not yet"
        }
    }
}

struct BadgeDetailRow: View {
    let badgeType: BadgeType
    let isEarned: Bool
    let progressText: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: badgeType.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(isEarned ? Color(hex: badgeType.color) : .gray.opacity(0.4))
                .frame(width: 42, height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isEarned ? Color(hex: badgeType.color).opacity(0.12) : Color.primary.opacity(0.04))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(badgeType.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(isEarned ? .primary : .secondary)

                Text(requirementText(for: badgeType))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(progressText)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(isEarned ? .green : .secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background((isEarned ? Color.green : Color.primary).opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(14)
        .background(Color(hex: "FFFDF9"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(isEarned ? 1 : 0.8)
    }

    private func requirementText(for badge: BadgeType) -> String {
        switch badge {
        case .firstDay:
            return "Stay no contact for 1 day"
        case .weekStreak:
            return "Stay no contact for 7 days"
        case .twoWeekStreak:
            return "Stay no contact for 14 days"
        case .monthStreak:
            return "Stay no contact for 30 days"
        case .deletedFolder:
            return "Delete photos power action"
        case .blockedEx:
            return "Block ex power action"
        case .unfollowedAll:
            return "Unfollow power action"
        case .firstJournal:
            return "Reality journaling power action"
        case .newExperience:
            return "New experience power action"
        case .glowUpReached:
            return "Reach the Glow-Up level"
        case .unbotheredReached:
            return "Reach the Unbothered level"
        }
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AnalyticsView()
                .environment(TrackingStore.previewNewUser)
                .environment(NotificationStore())
                .environment(previewUserProfile())
                .previewDisplayName("New User")
            
            AnalyticsView()
                .environment(TrackingStore.previewLevel1)
                .environment(NotificationStore())
                .environment(previewUserProfile())
                .previewDisplayName("Level 1 - Day 3")
            
            AnalyticsView()
                .environment(TrackingStore.previewLevel2WithProgress)
                .environment(NotificationStore())
                .environment(previewUserProfile())
                .previewDisplayName("Level 2 - With Progress")
            
            AnalyticsView()
                .environment(TrackingStore.previewLevel3WithRelapses)
                .environment(NotificationStore())
                .environment(previewUserProfile())
                .previewDisplayName("Level 3 - With Relapses")
            
            AnalyticsView()
                .environment(TrackingStore.previewLevel4NearLevelUp)
                .environment(NotificationStore())
                .environment(previewUserProfile())
                .previewDisplayName("Level 4 - Near Level Up")
            
            AnalyticsView()
                .environment(TrackingStore.previewLevel5)
                .environment(NotificationStore())
                .environment(previewUserProfile())
                .previewDisplayName("Level 5 - Unbothered")
            
            AnalyticsView()
                .environment(TrackingStore.previewJustRelapsed)
                .environment(NotificationStore())
                .environment(previewUserProfile())
                .previewDisplayName("Just Relapsed")
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
