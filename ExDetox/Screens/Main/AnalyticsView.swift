import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(NotificationStore.self) private var notificationStore
    @Environment(\.modelContext) private var modelContext
    
    @State private var animateProgress = false
    @State private var selectedTab: AnalyticsTab = .overview
    
    enum AnalyticsTab: String, CaseIterable {
        case overview = "Overview"
        case streaks = "Streaks"
        case actions = "Actions"
        case badges = "Badges"
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            tabPicker
            
            ScrollView {
                VStack(spacing: 24) {
                    switch selectedTab {
                    case .overview:
                        overviewContent
                    case .streaks:
                        streaksContent
                    case .actions:
                        actionsContent
                    case .badges:
                        badgesContent
                    }
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
    
    private var tabPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AnalyticsTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTab = tab
                        }
                    } label: {
                        Text(tab.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedTab == tab ? .bold : .medium)
                            .foregroundStyle(selectedTab == tab ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.black : Color.white)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(selectedTab == tab ? 0 : 0.05), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
    
    @ViewBuilder
    private var overviewContent: some View {
        levelProgressCard
        nextLevelPreviewCard
        freedomCountdownCard
        weeklyMoodCard
        statsGrid
        
        #if DEBUG
        debugControls
        #endif
    }
    
    @ViewBuilder
    private var streaksContent: some View {
        currentStreakCard
        weeklyStreakDetailCard
        streakHistoryCard
    }
    
    @ViewBuilder
    private var actionsContent: some View {
        speedUpSummaryCard
        powerActionsListCard
    }
    
    @ViewBuilder
    private var badgesContent: some View {
        badgesGridCard
    }
    
    private var levelProgressCard: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CURRENT LEVEL")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    Text(trackingStore.currentLevel.title)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Spacer()
                Text("Lvl \(trackingStore.currentLevel.index)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: trackingStore.currentLevel.color))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(trackingStore.currentLevel.emoji + " " + trackingStore.currentLevel.genZTagline)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: trackingStore.currentLevel.color), Color(hex: trackingStore.currentLevel.color).opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: animateProgress ? geometry.size.width * CGFloat(trackingStore.levelProgress) : 0, height: 12)
                            .animation(.spring(response: 1, dampingFraction: 0.8), value: animateProgress)
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text("\(Int(trackingStore.levelProgress * 100))% Complete")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    Spacer()
                    
                    if trackingStore.daysLeftInLevel > 0 {
                        Text("\(trackingStore.daysLeftInLevel) days to next level")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Color(hex: trackingStore.currentLevel.color))
                    } else {
                        Text("Final level reached! 🏆")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.green)
                    }
                }
            }
            
            Divider()
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Days in Level")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(trackingStore.daysInLevel)")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Min Required")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(trackingStore.currentLevel.minDays)")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Speed-Up Earned")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                        Text(String(format: "%.1f", trackingStore.bonusDays))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var nextLevelPreviewCard: some View {
        if let nextLevel = trackingStore.currentLevel.nextLevel {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Text("🔮")
                    Text("COMING UP")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(nextLevel.title)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text(nextLevel.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(nextLevel.emoji)
                        .font(.system(size: 40))
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("To unlock:")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundStyle(Color(hex: nextLevel.color))
                        Text("Keep no-contact for \(trackingStore.daysLeftInLevel) more days")
                            .font(.subheadline)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .foregroundStyle(.orange)
                        Text("Complete power actions to speed up (max \(trackingStore.currentLevel.maxBonusDays - Int(trackingStore.bonusDays)) more days)")
                            .font(.subheadline)
                    }
                }
            }
            .padding(24)
            .background(
                LinearGradient(
                    colors: [Color(hex: nextLevel.color).opacity(0.1), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(hex: nextLevel.color).opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }
    
    private var freedomCountdownCard: some View {
        VStack(alignment: .center, spacing: 24) {
            HStack(spacing: 8) {
                Text("🏁")
                Text("FREEDOM COUNTDOWN")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 24)
                    .opacity(0.1)
                    .foregroundColor(.secondary)
                
                Circle()
                    .trim(from: 0.0, to: animateProgress ? CGFloat(trackingStore.detoxProgress) : 0.0)
                    .stroke(style: StrokeStyle(lineWidth: 24, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(
                        LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.spring(response: 1.5, dampingFraction: 0.7), value: animateProgress)
                
                VStack(spacing: 4) {
                    Text("\(Int(trackingStore.detoxProgress * 100))%")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .contentTransition(.numericText(value: trackingStore.detoxProgress * 100))
                        .foregroundStyle(.primary)
                    
                    Text("\(trackingStore.daysLeftInProgram) days left")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 260, height: 260)
            .padding(.vertical, 12)
            
            Divider()
                .overlay(Color.primary.opacity(0.1))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Freedom Date")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    Text(trackingStore.freedomDate.formatted(date: .long, time: .omitted))
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Image(systemName: "flag.checkered")
                    .font(.title2)
                    .foregroundStyle(.green)
                    .padding(12)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(24)
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
                
                HStack(spacing: 24) {
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
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Check-Ins")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(trackingStore.dailyCheckIns.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
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
    
    private var currentStreakCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                Text("🔥")
                Text("CURRENT STREAK")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("\(trackingStore.currentStreakDays)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                Text("days")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            if trackingStore.currentStreakDays > 0 {
                Text(streakEncouragement)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Longest Streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                        Text("\(trackingStore.maxStreak) days")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                
                Spacer()
                
                if let lastRelapse = trackingStore.state.lastRelapseDate {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Last Relapse")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(lastRelapse.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
    
    private var streakEncouragement: String {
        switch trackingStore.currentStreakDays {
        case 1...3: return "Great start! Every day counts 💪"
        case 4...7: return "Almost a full week! You're doing amazing 🌟"
        case 8...14: return "Two weeks of growth! You're unstoppable 🚀"
        case 15...30: return "A whole month of healing! You're a legend ✨"
        case 31...60: return "You're in the glow-up zone now 🔥"
        case 61...90: return "Three months strong! Main character energy 🎬"
        default: return "Absolutely legendary. You've transcended 👑"
        }
    }
    
    private var weeklyStreakDetailCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("📅")
                Text("THIS WEEK")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            
            let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 8) {
                        Text(weekDays[index])
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        weekDayCircle(status: trackingStore.weekStatuses[index])
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Success Days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("\(trackingStore.state.successfulDaysThisWeek)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Relapse Days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                        Text("\(trackingStore.state.relapsesDaysThisWeek)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
            }
            
            if trackingStore.state.relapsesDaysThisWeek > 0 {
                Text("You slipped, but you didn't go back to zero as a person. Just the streak. Let's rebuild. 💪")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .background(Color.orange.opacity(0.1))
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
    private func weekDayCircle(status: Int) -> some View {
        let size: CGFloat = 40
        
        switch status {
        case 1:
            Circle()
                .fill(Color.green)
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                )
        case 2:
            Circle()
                .fill(Color.red)
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: "xmark")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                )
        default:
            Circle()
                .fill(Color.gray.opacity(0.15))
                .frame(width: size, height: size)
        }
    }
    
    private var streakHistoryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("📈")
                Text("STREAK STATS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Relapses")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(trackingStore.relapses)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Days in Program")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(trackingStore.daysSinceProgramStart)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
    
    private var speedUpSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("⚡️")
                Text("HEALING BOOSTS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Speed-Up Days Earned")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", trackingStore.bonusDays))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                        Text("days")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Max for Level")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(trackingStore.currentLevel.maxBonusDays)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.1))
                        .frame(height: 8)
                    
                    let maxBonus = max(trackingStore.currentLevel.maxBonusDays, 1)
                    let progress = min(trackingStore.bonusDays / Double(maxBonus), 1)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                }
            }
            .frame(height: 8)
            
            Text("You sped up your healing by doing hard things most people avoid. Keep it up!")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
    
    private var powerActionsListCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("💪")
                Text("COMPLETED ACTIONS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(trackingStore.powerActions.count) total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if trackingStore.powerActions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bolt.slash")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No power actions yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Complete actions from the Home tab to speed up your healing")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ForEach(trackingStore.powerActions.sorted(by: { $0.date > $1.date }).prefix(10)) { action in
                    HStack(spacing: 12) {
                        Image(systemName: action.type.icon)
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.purple)
                            .clipShape(Circle())
                        
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
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.03))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
    
    private var badgesGridCard: some View {
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
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(BadgeType.allCases, id: \.self) { badgeType in
                    let earned = trackingStore.badges.contains(where: { $0.type == badgeType })
                    
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
            
            if !trackingStore.badges.isEmpty {
                Divider()
                
                Text("Recently Earned")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                
                ForEach(trackingStore.badges.sorted(by: { $0.earnedDate > $1.earnedDate }).prefix(3)) { badge in
                    HStack(spacing: 12) {
                        Image(systemName: badge.type.icon)
                            .foregroundStyle(Color(hex: badge.type.color))
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(badge.type.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(badge.earnedDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(hex: badge.type.color).opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
    
    #if DEBUG
    private var debugControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("🧪")
                Text("DEBUG CONTROLS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Button("Test Daily Check-In") {
                        notificationStore.showDailyCheckIn()
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.05))
                    .clipShape(Capsule())
                    
                    Button("Test Challenge") {
                        notificationStore.showChallenge()
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.05))
                    .clipShape(Capsule())
                }
                
                HStack {
                    Button("Test Level-Up") {
                        notificationStore.showLevelUp(for: trackingStore.currentLevel)
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.05))
                    .clipShape(Capsule())
                    
                    Button("Test Relapse Support") {
                        notificationStore.showRelapseSupport()
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.05))
                    .clipShape(Capsule())
                }
                
                HStack {
                    Button("Add Power Action") {
                        TrackingPersistence.recordPowerAction(store: trackingStore, context: modelContext, type: .deletePhotos)
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.08))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
                    
                    Button("Log Relapse") {
                        TrackingPersistence.recordRelapse(store: trackingStore, context: modelContext)
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.08))
                    .foregroundStyle(.red)
                    .clipShape(Capsule())
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 20)
    }
    #endif
    
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
