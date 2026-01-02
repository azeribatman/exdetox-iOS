import SwiftUI
import SwiftData

struct ScreenshotsView: View {
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(NotificationStore.self) private var notificationStore
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(\.modelContext) private var modelContext
    
    private let creamBg = Color(hex: "F5F0E8")
    private let cardBg = Color(hex: "FFFDF9")
    
    var body: some View {
        NavigationStack {
            ZStack {
                creamBg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        headerSection
                        
                        mainScreensSection
                        
                        modalScreensSection
                        
                        detailScreensSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            setupMockData()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("📸")
                .font(.system(size: 60))
            
            Text("App Store Screenshots")
                .font(.system(size: 28, weight: .black, design: .rounded))
            
            Text("Select a screen to preview")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private var mainScreensSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MAIN SCREENS")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                screenshotCell(
                    icon: "house.fill",
                    title: "Home View",
                    subtitle: "Main dashboard with streak & timer",
                    color: .orange,
                    destination: HomeView()
                )
                
                Divider().padding(.leading, 68)
                
                screenshotCell(
                    icon: "chart.bar.fill",
                    title: "Analytics View",
                    subtitle: "Progress, stats & badges",
                    color: .blue,
                    destination: AnalyticsView()
                )
                
                Divider().padding(.leading, 68)
                
                screenshotCell(
                    icon: "message.fill",
                    title: "AI Agent View",
                    subtitle: "Supportive chat companion",
                    color: .purple,
                    destination: AiAgentView()
                )
                
                Divider().padding(.leading, 68)
                
                screenshotCell(
                    icon: "heart.fill",
                    title: "My Why View",
                    subtitle: "Reasons to stay strong",
                    color: .red,
                    destination: MyWhyView()
                )
                
                Divider().padding(.leading, 68)
                
                screenshotCell(
                    icon: "book.fill",
                    title: "Learning View",
                    subtitle: "Educational content & lessons",
                    color: .green,
                    destination: LearningView()
                )
            }
            .background(cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
    }
    
    private var modalScreensSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MODAL SCREENS")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                screenshotCell(
                    icon: "flame.fill",
                    title: "Roast Me",
                    subtitle: "Reality check humor",
                    color: .orange,
                    destination: RoastMeView()
                )
                
                Divider().padding(.leading, 68)
                
                screenshotCell(
                    icon: "wind",
                    title: "Meditate View",
                    subtitle: "Breathing exercise",
                    color: .mint,
                    destination: MeditateView()
                )
                
                Divider().padding(.leading, 68)
                
                screenshotCell(
                    icon: "exclamationmark.triangle.fill",
                    title: "Panic View",
                    subtitle: "Emergency support screen",
                    color: .red,
                    destination: PanicView()
                )
                
                Divider().padding(.leading, 68)
                
                screenshotCell(
                    icon: "gearshape.fill",
                    title: "Settings View",
                    subtitle: "Account & preferences",
                    color: .gray,
                    destination: SettingsView()
                )
            }
            .background(cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
    }
    
    private var detailScreensSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DETAIL SCREENS")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                screenshotCell(
                    icon: "bolt.fill",
                    title: "Power Actions",
                    subtitle: "Speed up healing",
                    color: .purple,
                    destination: PowerActionsSheet()
                )
                
                Divider().padding(.leading, 68)
                
                screenshotCell(
                    icon: "face.smiling",
                    title: "Daily Check-In",
                    subtitle: "Mood & urge tracking",
                    color: .blue,
                    destination: QuickCheckInSheet()
                )
                
                Divider().padding(.leading, 68)
                
                screenshotCell(
                    icon: "star.fill",
                    title: "Badges Sheet",
                    subtitle: "All achievements",
                    color: .yellow,
                    destination: BadgesSheet()
                )
                
                Divider().padding(.leading, 68)
                
                screenshotCell(
                    icon: "list.bullet",
                    title: "All Levels",
                    subtitle: "Healing journey stages",
                    color: .indigo,
                    destination: AllLevelsSheet()
                )
                
                Divider().padding(.leading, 68)
                
                screenshotCell(
                    icon: "doc.text.fill",
                    title: "Article Detail",
                    subtitle: "Learning content",
                    color: .mint,
                    destination: ArticleDetailView(
                        article: sampleArticle,
                        onComplete: {}
                    )
                )
            }
            .background(cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
    }
    
    private func screenshotCell<Destination: View>(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        destination: Destination
    ) -> some View {
        NavigationLink(destination: destination.navigationBarBackButtonHidden()) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.quaternary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var sampleArticle: Article {
        Article(
            title: "The Science of Moving On",
            subtitle: "Understanding the psychology behind breakups",
            category: "Detox Your Ex",
            readTime: "3–5 min",
            imageColor: .orange,
            tldr: "Your brain treats breakups like actual withdrawal. Here's why it's so hard.",
            action: "Write down 3 red flags you ignored",
            quote: LessonQuote(
                persona: "Dr. Sarah",
                text: "Healing isn't linear, but it is inevitable."
            ),
            quiz: [
                QuizQuestion(
                    question: "What's the healthiest first step after a breakup?",
                    options: [
                        QuizOption(id: "a", text: "Immediately start dating again"),
                        QuizOption(id: "b", text: "Block them everywhere and focus on yourself"),
                        QuizOption(id: "c", text: "Try to stay friends"),
                        QuizOption(id: "d", text: "Keep checking their socials")
                    ],
                    correctOptionId: "b",
                    explanation: "Going no-contact gives you space to heal without triggering memories."
                )
            ],
            content: [
                "When you go through a breakup, your brain literally goes into withdrawal.",
                "Research shows that the same neural pathways activated during drug addiction light up when we're heartbroken.",
                "This is why texting your ex at 2 AM feels like a compulsion you can't control.",
                "But here's the thing: every day you resist that urge, you're rewiring your brain.",
                "Your neural pathways are literally healing and creating new connections.",
                "It takes about 90 days for your brain to significantly adapt to the absence of someone you were attached to.",
                "That's not arbitrary - it's science.",
                "So when people say 'time heals all wounds,' they're not wrong. But it's not just time - it's what you do with that time.",
                "Every day you choose yourself, you're one step closer to freedom."
            ]
        )
    }
    
    private func setupMockData() {
        guard userProfileStore.hasCompletedOnboarding else { return }
        
        TrackingPersistence.bootstrap(store: trackingStore, context: modelContext)
        
        let calendar = Calendar.current
        let now = Date()
        
        if !trackingStore.hasCheckedInToday {
            TrackingPersistence.recordDailyCheckIn(
                store: trackingStore,
                context: modelContext,
                mood: 4,
                urge: 3
            )
        }
        
        guard (try? modelContext.fetchCount(FetchDescriptor<WhyItemRecord>())) == 0 else { return }
        
        let whyItems = [
            WhyItemRecord(
                title: "He forgot to buy me a Christmas gift and acted like it wasn’t a big deal",
                imageFileName: nil
            ),
            WhyItemRecord(
                title: "He forgot my birthday and blamed it on being 'busy with work'",
                imageFileName: nil
            ),
            WhyItemRecord(
                title: "Always made me feel like I was asking for too much when I just wanted basic respect",
                imageFileName: nil
            ),
            WhyItemRecord(
                title: "Said 'I love you' but his actions never matched his words",
                imageFileName: nil
            )
        ]
        
        whyItems.forEach { item in
            let adjustedItem = WhyItemRecord(
                title: item.title,
                imageFileName: item.imageFileName
            )
            adjustedItem.createdAt = calendar.date(byAdding: .day, value: -whyItems.firstIndex(of: item)!, to: now) ?? now
            modelContext.insert(adjustedItem)
        }
        
        try? modelContext.save()
    }
}

#Preview {
    ScreenshotsView()
        .environment(TrackingStore.previewLevel2WithProgress)
        .environment(NotificationStore())
        .environment(UserProfileStore.previewProfile())
        .modelContainer(for: [
            TrackingRecord.self,
            RelapseRecord.self,
            PowerActionObject.self,
            DailyCheckInRecord.self,
            BadgeRecord.self,
            UserProfileRecord.self,
            WhyItemRecord.self
        ], inMemory: true)
}
