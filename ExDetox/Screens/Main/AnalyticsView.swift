import SwiftUI

struct AnalyticsView: View {
    // Mock Data (matching HomeView logic where possible)
    let startDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
    let totalDetoxDays: Double = 90 // Example: 90 days full detox
    let currentLevelName = "The Awakening"
    let currentLevelTotalDays: Double = 30
    
    // Computed Properties
    var daysSinceStart: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
    }
    
    var progress: Double {
        min(Double(daysSinceStart) / totalDetoxDays, 1.0)
    }
    
    var levelProgress: Double {
        min(Double(daysSinceStart) / currentLevelTotalDays, 1.0)
    }
    
    var daysLeftInLevel: Int {
        max(Int(currentLevelTotalDays) - daysSinceStart, 0)
    }
    
    var endDate: Date {
        Calendar.current.date(byAdding: .day, value: Int(totalDetoxDays), to: startDate) ?? Date()
    }
    
    // Stats
    let maxStreak = 12
    let relapses = 1
    
    @State private var animateProgress = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
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
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Level Progress Section
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("CURRENT LEVEL")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.secondary)
                                Text(currentLevelName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            Text("Lvl 1")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        
                        // Level Progress Bar
                        VStack(spacing: 8) {
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(height: 12)
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .frame(width: animateProgress ? geometry.size.width * CGFloat(levelProgress) : 0, height: 12)
                                        .animation(.spring(response: 1, dampingFraction: 0.8), value: animateProgress)
                                }
                            }
                            .frame(height: 12)
                            
                            HStack {
                                Text("\(Int(levelProgress * 100))% Complete")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(daysLeftInLevel) days to next level")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.indigo)
                            }
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    
                    // Overall Progress (The "End" Date)
                    VStack(alignment: .center, spacing: 24) {
                        HStack(spacing: 8) {
                            Text("🏁")
                            Text("FREEDOM COUNTDOWN")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Circular Progress
                        ZStack {
                            // Background Circle
                            Circle()
                                .stroke(lineWidth: 24)
                                .opacity(0.1)
                                .foregroundColor(.secondary)
                            
                            // Progress Circle
                            Circle()
                                .trim(from: 0.0, to: animateProgress ? CGFloat(progress) : 0.0)
                                .stroke(style: StrokeStyle(lineWidth: 24, lineCap: .round, lineJoin: .round))
                                .foregroundStyle(
                                    LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .rotationEffect(Angle(degrees: 270.0))
                                .animation(.spring(response: 1.5, dampingFraction: 0.7), value: animateProgress)
                            
                            // Center Content
                            VStack(spacing: 4) {
                                Text("\(Int(progress * 100))%")
                                    .font(.system(size: 56, weight: .bold, design: .rounded))
                                    .contentTransition(.numericText(value: progress * 100))
                                    .foregroundStyle(.primary)
                                
                                Text("\(Int(totalDetoxDays) - daysSinceStart) days left")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(width: 260, height: 260)
                        .padding(.vertical, 12)
                        
                        Divider()
                            .overlay(Color.primary.opacity(0.1))
                        
                        // Date Info
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Freedom Date")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                
                                Text(endDate.formatted(date: .long, time: .omitted))
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
                    
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        statCard(title: "Current Streak", value: "\(daysSinceStart)", unit: "days", icon: "flame.fill", color: .orange)
                        statCard(title: "Max Streak", value: "\(maxStreak)", unit: "days", icon: "trophy.fill", color: .yellow)
                        statCard(title: "Relapses", value: "\(relapses)", unit: "times", icon: "arrow.counterclockwise", color: .red)
                        statCard(title: "Start Date", value: startDate.formatted(.dateTime.day().month()), unit: String(startDate.formatted(.dateTime.year())), icon: "calendar", color: .blue)
                    }
                    .padding(.horizontal, 20)
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

#Preview {
    AnalyticsView()
}
