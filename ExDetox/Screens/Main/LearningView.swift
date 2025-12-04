import SwiftUI

struct LearningView: View {
    // Mock Data
    let sounds = [
        ("Rain", "cloud.rain.fill", Color.blue),
        ("Ocean", "water.waves", Color.teal),
        ("Forest", "tree.fill", Color.green),
        ("Fire", "flame.fill", Color.orange)
    ]
    
    let articles = [
        Article(
            title: "The Science of No Contact",
            subtitle: "Why silence speaks louder than words",
            category: "Psychology",
            readTime: "5 min",
            imageColor: .indigo,
            content: [
                "No contact is not just a strategy to get your ex back. It is a powerful tool for your own healing and reclaiming your self-worth.",
                "When you silence the noise of the relationship, you can finally hear your own thoughts. Use this time to rediscover who you are.",
                "It sends a message that you respect yourself enough to walk away from what no longer serves you."
            ]
        ),
        Article(
            title: "Rebuilding Your Identity",
            subtitle: "Who are you without them?",
            category: "Self Growth",
            readTime: "7 min",
            imageColor: .purple,
            content: [
                "It's easy to lose yourself in a relationship. Now is the time to pick up the pieces and build something even more beautiful.",
                "Start by revisiting old hobbies, reconnecting with friends, and setting new goals for yourself.",
                "You are the architect of your own life. Design a future that excites you."
            ]
        ),
        Article(
            title: "Red Flags You Missed",
            subtitle: "Learning from the past",
            category: "Reflection",
            readTime: "4 min",
            imageColor: .red,
            content: [
                "Hindsight is 20/20. Looking back, you might see signs that you ignored in the name of love.",
                "Acknowledge them, not to blame yourself, but to learn. This knowledge is your armor for the future.",
                "Never settle for less than you deserve again."
            ]
        ),
        Article(
            title: "The Dopamine Detox",
            subtitle: "Resetting your brain chemistry",
            category: "Health",
            readTime: "6 min",
            imageColor: .mint,
            content: [
                "Breakups can feel like withdrawal because love activates the same reward centers in the brain as addiction.",
                "By detoxing from constant contact and reminders, you allow your brain to reset and find balance.",
                "Embrace the calm. It's the first step towards true freedom."
            ]
        )
    ]
    
    @ObservedObject private var audioManager = AudioManager.shared
    @State private var showSettings = false
    @State private var selectedArticle: Article?
    @State private var streakCount = 3
    @State private var igniteAnimationTrigger = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
                .background(Color(hex: "F9F9F9"))
            
            ScrollView {
                VStack(spacing: 24) {
                    // Learning Streak
                    streakSection
                    
                    // Relaxing Sounds
                    soundsSection
                    
                    // Articles
                    articlesSection
                }
                .padding(.bottom, 40)
                .padding(.top, 24)
            }
        }
        .background(Color(hex: "F9F9F9").ignoresSafeArea())
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(item: $selectedArticle) { article in
            ArticleDetailView(article: article, onComplete: {
                igniteStreak()
            })
        }
    }
    
    func igniteStreak() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            if streakCount < 5 {
                streakCount += 1
                igniteAnimationTrigger = true
            }
        }
        
        // Reset animation trigger
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            igniteAnimationTrigger = false
        }
    }
    
    // MARK: - Subviews
    
    var headerView: some View {
        HStack {
            Text("Learning")
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
    }
    
    var streakSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("🔥")
                    .font(.title3)
                Text("LEARNING STREAK")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 20) {
                // Fire Icons Row (Article Based)
                HStack(spacing: 12) {
                    ForEach(0..<5) { index in
                        VStack(spacing: 8) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(index < streakCount ? Color.orange : Color.gray.opacity(0.2))
                                .shadow(color: index < streakCount ? .orange.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                                .scaleEffect(index == streakCount - 1 && igniteAnimationTrigger ? 1.5 : 1.0)
                            
                            // Article Count Labels
                            if index < streakCount {
                                Text("#\(index + 1)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.orange)
                            } else {
                                Text("#\(index + 1)")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                
                Divider()
                    .overlay(Color.primary.opacity(0.1))
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(streakCount) Articles Read")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        Text(streakCount < 5 ? "Read \(5 - streakCount) more to complete your goal!" : "Goal completed! Great job!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(streakCount) / 5.0)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(-90))
                        .background(
                            Circle()
                                .stroke(Color.gray.opacity(0.1), lineWidth: 4)
                        )
                        .overlay(
                            Text("\(streakCount)/5")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.primary)
                        )
                        .animation(.easeInOut, value: streakCount)
                }
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 20)
    }
    
    var soundsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("🎧")
                    .font(.title3)
                Text("RELAXING SOUNDS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(sounds, id: \.0) { sound in
                        Button(action: {
                            audioManager.playSound(named: sound.0)
                        }) {
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(sound.2.opacity(0.1))
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Image(systemName: sound.1)
                                            .font(.title3)
                                            .foregroundStyle(sound.2)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(sound.0)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.primary)
                                        .fixedSize(horizontal: true, vertical: false)
                                    
                                    Text(audioManager.currentSound == sound.0 && audioManager.isPlaying ? "Playing..." : "Tap to play")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundStyle(audioManager.currentSound == sound.0 && audioManager.isPlaying ? .orange : .secondary)
                                }
                                
                                Spacer(minLength: 0)
                                
                                Image(systemName: audioManager.currentSound == sound.0 && audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(audioManager.currentSound == sound.0 && audioManager.isPlaying ? .orange : Color.gray.opacity(0.3))
                            }
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(audioManager.currentSound == sound.0 && audioManager.isPlaying ? Color.orange.opacity(0.5) : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 2) // Add padding for shadow
            }
        }
    }
    
    var articlesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("📚")
                    .font(.title3)
                Text("ARTICLES")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24) // Match alignment
            
            VStack(spacing: 16) {
                ForEach(articles) { article in
                    Button(action: {
                        selectedArticle = article
                    }) {
                        HStack(spacing: 16) {
                            // Article Image Placeholder
                            Rectangle()
                                .fill(article.imageColor.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    Image(systemName: "doc.text.fill")
                                        .foregroundStyle(article.imageColor)
                                )
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(article.category.uppercased())
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(article.imageColor)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(article.imageColor.opacity(0.1))
                                        .clipShape(Capsule())
                                    
                                    Spacer()
                                    
                                    Text(article.readTime)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Text(article.title)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                
                                Text(article.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle()) // Prevent default button style effect
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Models

struct Article: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: String
    let readTime: String
    let imageColor: Color
    var content: [String] = [] // Added content property
}

#Preview {
    LearningView()
}
