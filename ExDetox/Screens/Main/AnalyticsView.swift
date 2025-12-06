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

    var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView {
                VStack(spacing: 24) {
                    mainContent
                }
                .padding(.bottom, 40)
            }
        }
        .background(Color(hex: "F9F9F9").ignoresSafeArea())
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
    }
    
    private var headerView: some View {
        HStack {
            Text("Analytics 📊")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .frame(height: 62)
        .padding(.horizontal, 20)
        .background(Color(hex: "F9F9F9"))
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
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                Text(trackingStore.currentLevel.emoji)
                    .font(.system(size: 44))
                    .padding(12)
                    .background(Color(hex: trackingStore.currentLevel.color).opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Where you are now")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    Text(trackingStore.currentLevel.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Level \(trackingStore.currentLevel.index)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                if trackingStore.daysLeftInLevel <= 0 {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                        .font(.title2)
                }
            }
            
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 12)
                        
                        Capsule()
                            .fill(Color(hex: trackingStore.currentLevel.color))
                            .frame(width: animateProgress ? geometry.size.width * CGFloat(trackingStore.levelProgress) : 0, height: 12)
                            .animation(.spring(response: 1, dampingFraction: 0.8), value: animateProgress)
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text("\(Int(trackingStore.levelProgress * 100))% done")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: trackingStore.currentLevel.color))
                    
                    Spacer()
                    
                    if trackingStore.daysLeftInLevel > 0 {
                        Text("\(trackingStore.daysLeftInLevel) days to next level")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Completed! 🏆")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                    }
                }
            }

            if let nextLevel = trackingStore.currentLevel.nextLevel {
                Divider()

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NEXT LEVEL")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            Text(nextLevel.emoji)
                                .font(.title2)
                                .padding(10)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(nextLevel.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text("Level \(nextLevel.index)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Spacer()

                    Button {
                        showAllLevels = true
                    } label: {
                        Text("See all")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
                .padding(16)
                .background(
                    LinearGradient(
                        colors: [
                            Color(hex: nextLevel.color).opacity(0.35),
                            Color(hex: nextLevel.color).opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    private var freedomCountdownCard: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 8)
                    .opacity(0.1)
                    .foregroundColor(.secondary)
                
                Circle()
                    .trim(from: 0.0, to: animateProgress ? CGFloat(trackingStore.detoxProgress) : 0.0)
                    .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(
                        LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.spring(response: 1.5, dampingFraction: 0.7), value: animateProgress)
                
                Text("\(Int(trackingStore.detoxProgress * 100))%")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("FREEDOM COUNTDOWN")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                
                Text("\(trackingStore.daysLeftInProgram) days left")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Until \(trackingStore.freedomDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var weeklyMoodCard: some View {
        if !trackingStore.dailyCheckIns.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Text("🧠")
                    Text("WEEKLY MOOD")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Avg Mood")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Text(String(format: "%.1f", trackingStore.state.averageMoodThisWeek))
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("/5")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Avg Urge")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Text(String(format: "%.1f", trackingStore.state.averageUrgeThisWeek))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(urgeColor(Int(trackingStore.state.averageUrgeThisWeek)))
                            Text("/10")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Check-Ins")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(trackingStore.dailyCheckIns.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(24)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 20)
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
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
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
        .padding(.horizontal, 20)
    }

    private var powerActionsSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("⚡️")
                Text("POWER ACTION DAYS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            let days = trackingStore.bonusDays

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(String(format: "%.1f", days))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                Text("days faster")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            Text("Doing brave actions makes your healing move ahead by these days.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                showPowerActionsSheet = true
            } label: {
                HStack {
                    Text("Do a power action")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.subheadline.bold())
                }
                .foregroundStyle(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }

    private var badgesPreviewCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("🏅")
                Text("YOUR BADGES")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(trackingStore.badges.count)/\(BadgeType.allCases.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            let allTypes = BadgeType.allCases
            let earnedTypes = Set(trackingStore.badges.map(\.type))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(allTypes.prefix(6), id: \.self) { badgeType in
                    let earned = earnedTypes.contains(badgeType)

                    VStack(spacing: 8) {
                        Image(systemName: badgeType.icon)
                            .font(.title2)
                            .foregroundStyle(earned ? Color(hex: badgeType.color) : .gray.opacity(0.3))
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(earned ? Color(hex: badgeType.color).opacity(0.15) : Color.gray.opacity(0.05))
                            )

                        Text(badgeType.title)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(earned ? .primary : .secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .opacity(earned ? 1 : 0.5)
                }
            }

            Button {
                showBadgesSheet = true
            } label: {
                Text("See all badges")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    func statCard(title: String, value: String, unit: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct AllLevelsSheet: View {
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("All Levels")
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
                VStack(spacing: 16) {
                    ForEach(HealingLevel.allCases, id: \.self) { level in
                        LevelDetailRow(level: level, currentLevel: trackingStore.currentLevel)
                    }
                }
                .padding(20)
            }
        }
        .background(Color(hex: "F9F9F9").ignoresSafeArea())
    }
}

struct LevelDetailRow: View {
    let level: HealingLevel
    let currentLevel: HealingLevel
    
    var isUnlocked: Bool {
        level.rawValue <= currentLevel.rawValue
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(level.emoji)
                    .font(.title)
                    .padding(8)
                    .background(Color(hex: level.color).opacity(0.1))
                    .clipShape(Circle())
                    .grayscale(isUnlocked ? 0 : 1)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(isUnlocked ? .primary : .secondary)
                    
                    Text("Level \(level.index)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.secondary.opacity(0.5))
                } else if level == currentLevel {
                     Text("Current")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .clipShape(Capsule())
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            
            Text(level.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if !isUnlocked {
                Divider()
                HStack(spacing: 6) {
                    Image(systemName: "lock")
                        .font(.caption)
                    Text("Unlocks after \(level.minDays) days no contact")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .opacity(isUnlocked ? 1 : 0.7)
    }
}

struct BadgesSheet: View {
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(BadgeType.allCases, id: \.self) { badgeType in
                        BadgeDetailRow(
                            badgeType: badgeType,
                            isEarned: trackingStore.badges.contains(where: { $0.type == badgeType }),
                            progressText: progressText(for: badgeType)
                        )
                    }
                }
                .padding(20)
            }
            .background(Color(hex: "F9F9F9"))
            .navigationTitle("Badges")
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
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: badgeType.icon)
                    .font(.title2)
                    .foregroundStyle(isEarned ? Color(hex: badgeType.color) : .gray.opacity(0.4))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(isEarned ? Color(hex: badgeType.color).opacity(0.15) : Color.gray.opacity(0.05))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(badgeType.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(isEarned ? .primary : .secondary)

                    Text(requirementText(for: badgeType))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(progressText)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(isEarned ? .green : .secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((isEarned ? Color.green : Color.gray).opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .opacity(isEarned ? 1 : 0.8)
    }

    private func requirementText(for badge: BadgeType) -> String {
        switch badge {
        case .firstDay:
            return "Stay no contact for 1 full day."
        case .weekStreak:
            return "Stay no contact for 7 days in a row."
        case .twoWeekStreak:
            return "Stay no contact for 14 days in a row."
        case .monthStreak:
            return "Stay no contact for 30 days in a row."
        case .deletedFolder:
            return "Do the \"Deleted Photos\" power action."
        case .blockedEx:
            return "Do the \"Blocked\" power action."
        case .unfollowedAll:
            return "Do the \"Unfollowed\" power action."
        case .firstJournal:
            return "Do the \"Reality Journaling\" power action."
        case .newExperience:
            return "Do the \"New Experience\" power action."
        case .glowUpReached:
            return "Reach the Glow-Up level in your journey."
        case .unbotheredReached:
            return "Reach the Unbothered level in your journey."
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
