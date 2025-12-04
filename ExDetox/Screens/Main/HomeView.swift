import SwiftUI
import Combine

struct HomeView: View {
    // Mock Data for Streak
    let weekDays = ["M", "T", "W", "T", "F", "S", "S"]
    // Simple status: 0: future/empty, 1: success, 2: fail
    let weekStatus = [1, 1, 2, 1, 0, 0, 0]
    
    // Timer properties
    @State private var timeComponents: (days: String, hours: String, minutes: String, seconds: String) = ("00", "00", "00", "00")
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Mock Start Date
    let startDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
    
    // Phase Progress
    let phaseTotalDays: Double = 30
    var currentPhaseDays: Double {
        let components = Calendar.current.dateComponents([.day], from: startDate, to: Date())
        return Double(components.day ?? 0)
    }
    
    // Phase Rules/Tags
    let phaseTags = ["No Texting 🚫", "No Stalking 🕵️‍♀️", "Self Focus ✨", "Healing ❤️‍🩹"]
    
    // Theme Colors
    let accentColor = Color.black

    @State private var showSettings = false
    @State private var showRoastMe = false
    @State private var showMeditate = false
    @State private var showPanic = false
    
    // Shared Data
    @State private var whyItems: [WhyItem] = [
        WhyItem(title: "He never listened to me when I was crying."),
        WhyItem(title: "Forgot my birthday... again.", imageName: "photo"),
        WhyItem(title: "Gaslighting 101.")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Hey, Aykhan 👋")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button(action: {
                    showSettings = true
                }) {
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

            ScrollView {
                VStack(spacing: 24) {
                    // Week Streak Section
                VStack(alignment: .leading, spacing: 16) {
                    // Section Header
                    HStack(spacing: 8) {
                        Text("📅") // Emoji for 3D vibe
                        Text("THIS WEEK")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
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
                                    
                                    streakCircle(status: weekStatus[index])
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        
                        Divider()
                            .overlay(Color.primary.opacity(0.1))
                        
                        Text("Don't let the ex win. Keep it green! 🤢")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(20)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 20)
                
                // No Contact Timer Section
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("NO CONTACT")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                            Text("Healing in progress")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .lastTextBaseline, spacing: 12) {
                            // Days (Big)
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text(timeComponents.days)
                                    .font(.system(size: 64, weight: .bold, design: .rounded))
                                    .contentTransition(.numericText(value: Double(timeComponents.days) ?? 0))
                                    .foregroundStyle(.primary)
                                
                                Text("days")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.secondary)
                            }
                            
                            // Time Details (Small)
                            HStack(spacing: 8) {
                                timeUnit(value: timeComponents.hours, unit: "hr")
                                timeUnit(value: timeComponents.minutes, unit: "min")
                                timeUnit(value: timeComponents.seconds, unit: "sec")
                            }
                            .padding(.bottom, 6)
                        }
                        
                        // Interesting Stats
                        HStack(spacing: 12) {
                            HStack(spacing: 6) {
                                Image(systemName: "heart.slash.fill")
                                    .foregroundStyle(.pink)
                                Text("Simp Lvl: 0")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.pink.opacity(0.1))
                            .clipShape(Capsule())
                            
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(.indigo)
                                Text("Glow Up Era ✨")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.indigo.opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(24)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
                
                // Quick Actions Section
                VStack(alignment: .leading, spacing: 12) {
                    // Section Header
                    HStack(spacing: 8) {
                        Text("⚡️")
                            .font(.title3)
                        Text("ACTIONS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 4)
                    
                    VStack(spacing: 0) {
                        actionRow(title: "Roast Me", icon: "flame.fill", color: .orange) {
                            showRoastMe = true
                        }
                        
                        Divider()
                            .padding(.leading, 54)
                        
                        actionRow(title: "Meditate", icon: "brain.head.profile", color: .teal) {
                            showMeditate = true
                        }
                        
                        Divider()
                            .padding(.leading, 54)

                        actionRow(title: "Reset Progress", icon: "arrow.counterclockwise", color: .red) {
                             showPanic = true
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 20)
                
                // Gen Z Quote Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Text("✨")
                            .font(.title3)
                        Text("DAILY REALITY CHECK")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 4)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("He’s prob watching reels rn. You should go slay your goals instead 💅✨")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(.primary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .padding(.top, 24)
                }
            }
            .safeAreaInset(edge: .bottom) {
                 Button(action: {
                     showPanic = true
                 }) {
                     HStack {
                         Image(systemName: "exclamationmark.triangle.fill")
                         .font(.headline)
                         Text("PANIC BUTTON 🚨")
                             .font(.headline)
                             .fontWeight(.bold)
                     }
                     .foregroundColor(.white)
                     .frame(maxWidth: .infinity)
                     .padding()
                     .background(Color.red)
                     .clipShape(RoundedRectangle(cornerRadius: 16))
                     .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                     .padding(20)
                 }
                 .background(
                    LinearGradient(colors: [Color(hex: "F9F9F9").opacity(0), Color(hex: "F9F9F9")], startPoint: .top, endPoint: .bottom)
                 )
            }
        }
        .background(Color(hex: "F9F9F9").ignoresSafeArea())
        .onReceive(timer) { _ in
            updateTimer()
        }
        .onAppear {
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
    }
    
    func updateTimer() {
        let diff = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: startDate, to: Date())
        let days = String(diff.day ?? 0)
        let hours = String(format: "%02d", diff.hour ?? 0)
        let minutes = String(format: "%02d", diff.minute ?? 0)
        let seconds = String(format: "%02d", diff.second ?? 0)
        
        timeComponents = (days, hours, minutes, seconds)
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
        case 1: // Success
            Circle()
                .fill(Color.green.opacity(0.2))
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                )
                .shadow(color: .green.opacity(0.1), radius: 2, x: 0, y: 2)
        case 2: // Failed
            Circle()
                .fill(Color.red.opacity(0.1))
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: "xmark")
                        .font(.caption.bold())
                        .foregroundColor(.red)
                )
        default: // Future/Empty
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: size, height: size)
        }
    }
    
    @ViewBuilder
    func actionRow(title: String, icon: String, color: Color, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(.black)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
        }
    }
}

// MARK: - Layouts
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = flow(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = flow(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = result.points[index]
            subview.place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
        }
    }
    
    private func flow(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, points: [CGPoint]) {
        let containerWidth = proposal.width ?? .infinity
        var points: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX > 0 && currentX + size.width > containerWidth {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            points.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            
            maxWidth = max(maxWidth, currentX + size.width)
            currentX += size.width + spacing
        }
        
        return (CGSize(width: maxWidth, height: currentY + lineHeight), points)
    }
}

#Preview {
    HomeView()
}

