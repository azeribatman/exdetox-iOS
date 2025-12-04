import SwiftUI
import AVKit

struct ArticleDetailView: View {
    let article: Article
    var onComplete: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var currentPage = 0
    @State private var showVideoPlayer = false
    @State private var isPlayingMusic = true
    @State private var audioPlayer: AVAudioPlayer?
    
    // Mock story content if article content is missing
    var pages: [String] {
        if !article.content.isEmpty {
            return article.content
        }
        return [
            "This is the beginning of your journey. Take a deep breath and let the words guide you.",
            "Understanding the process is key to healing. It's not about forgetting, it's about growing.",
            "Every step forward, no matter how small, is a victory. Celebrate your progress.",
            "You are stronger than you know. Keep pushing forward and never look back."
        ]
    }
    
    var body: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    Text("Reading")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    // Music Toggle
                    Button(action: {
                        isPlayingMusic.toggle()
                        if isPlayingMusic {
                            playMusic()
                        } else {
                            audioPlayer?.pause()
                        }
                    }) {
                        Image(systemName: isPlayingMusic ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(isPlayingMusic ? .orange : .gray)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                
                // Story Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 24) {
                            Spacer()
                            
                            // Article Image/Icon for the page
                            Circle()
                                .fill(article.imageColor.opacity(0.1))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "book.fill")
                                        .font(.system(size: 48))
                                        .foregroundStyle(article.imageColor)
                                )
                                .padding(.bottom, 20)
                            
                            Text(pages[index])
                                .font(.system(size: 20, weight: .medium, design: .serif))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(8)
                                .padding(.horizontal, 32)
                            
                            if index == 1 { // Show video button on 2nd page as example
                                Button(action: {
                                    showVideoPlayer = true
                                }) {
                                    HStack {
                                        Image(systemName: "play.circle.fill")
                                        Text("Watch Video")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.black)
                                    .clipShape(Capsule())
                                }
                                .padding(.top, 20)
                            }
                            
                            Spacer()
                            
                            if index == pages.count - 1 {
                                Button(action: {
                                    onComplete()
                                    dismiss()
                                }) {
                                    Text("Finish & Ignite 🔥")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.orange)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .padding(.horizontal, 40)
                                .padding(.bottom, 40)
                            } else {
                                Text("Swipe to continue")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom, 40)
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
            
            // Video Player Overlay
            if showVideoPlayer {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showVideoPlayer = false
                    }
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            showVideoPlayer = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    
                    // Video Player placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black)
                            .aspectRatio(16/9, contentMode: .fit)
                        
                        Text("Video Player")
                            .foregroundStyle(.white)
                        
                        Image(systemName: "play.circle")
                            .font(.system(size: 50))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding()
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            playMusic()
        }
        .onDisappear {
            audioPlayer?.stop()
        }
    }
    
    func playMusic() {
        // Mock music playing logic
        // In a real app, you would load a URL here
        print("Playing soothing background music...")
    }
}

#Preview {
    ArticleDetailView(
        article: Article(
            title: "Test",
            subtitle: "Subtitle",
            category: "Test",
            readTime: "5m",
            imageColor: .blue
        ),
        onComplete: {}
    )
}


