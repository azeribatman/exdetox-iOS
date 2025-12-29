import SwiftUI
import SwiftData
import AppsFlyerLib

struct PanicView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(NotificationStore.self) private var notificationStore
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WhyItemRecord.createdAt, order: .reverse) private var whyItems: [WhyItemRecord]
    @State private var showMeditate = false
    @State private var showAddWhy = false
    @State private var showRelapseConfirm = false
    
    @State private var animateWarning = false
    @State private var pulseEmoji = false
    @State private var shakeIntensity: CGFloat = 0
    @State private var currentQuoteIndex = 0
    
    private let sosQuotes = [
        "PUT. THE. PHONE. DOWN. 📱🚫",
        "They're not worth your peace 🧘‍♀️",
        "You've come too far to go back now 🏃‍♀️",
        "Block, breathe, and be blessed 🙏",
        "This urge is temporary. Your growth is forever 🌱",
        "You are NOT going to throw away your progress 💪",
        "Bestie, this is NOT the move 🙅‍♀️",
        "Close this chat. Touch some grass. 🌿",
        "They don't deserve rent-free space in your head 🏠",
        "Your future self will THANK you for this 🙌"
    ]
    
    private func documentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    private func loadImage(from fileName: String) -> UIImage? {
        guard let directory = documentsDirectory() else { return nil }
        let url = directory.appendingPathComponent(fileName)
        return UIImage(contentsOfFile: url.path)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    if !whyItems.isEmpty {
                        myWhysContent
                    } else {
                        emptyStateContent
                    }
                }
                .padding(.bottom, 140)
            }
            .safeAreaInset(edge: .bottom) {
                bottomButtons
            }
        }
        .background(Color(hex: "F9F9F9").ignoresSafeArea())
        .onAppear {
            startAnimations()
            // Track panic view content view (when opened as sheet)
            AnalyticsManager.shared.trackContentView(contentId: "panic_view", contentType: "sos_screen")
        }
        .sheet(isPresented: $showMeditate) {
            MeditateView()
        }
        .sheet(isPresented: $showAddWhy) {
            AddWhyView { title, image in
                var fileName: String?
                if let image {
                    fileName = saveImageToDocuments(image)
                }
                let newItem = WhyItemRecord(title: title, imageFileName: fileName)
                modelContext.insert(newItem)
                try? modelContext.save()
            }
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
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will reset your streak. It's okay—slipping doesn't erase your progress. We're here to help you rebuild.")
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("SOS Mode 🚨")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private var myWhysContent: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("🛑")
                    .font(.system(size: 60))
                    .scaleEffect(pulseEmoji ? 1.2 : 1.0)
                
                Text("NOOOO! DON'T DO IT!")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.red)
                    .scaleEffect(animateWarning ? 1.05 : 1.0)
                
                Text("Remember why you started:")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 12)
            
            ForEach(whyItems) { item in
                VStack(alignment: .leading, spacing: 12) {
                    if let fileName = item.imageFileName, let uiImage = loadImage(from: fileName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Text(item.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var emptyStateContent: some View {
        VStack(spacing: 28) {
            Spacer().frame(height: 20)
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseEmoji ? 1.15 : 1.0)
                    
                    Text("🚨")
                        .font(.system(size: 56))
                        .scaleEffect(pulseEmoji ? 1.1 : 1.0)
                        .offset(x: shakeIntensity)
                }
                
                Text("HOLD UP BESTIE")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "FF3B30"))
                    .scaleEffect(animateWarning ? 1.05 : 1.0)
            }
            
            VStack(spacing: 20) {
                Text(sosQuotes[currentQuoteIndex])
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 24)
                    .id(currentQuoteIndex)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
                VStack(spacing: 8) {
                    Text("⏰ You've been clean for")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    Text("\(trackingStore.currentStreakDays) days")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "34C759"))
                    
                    Text("Don't throw this away! 💎")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 32)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
            }
            
            VStack(spacing: 16) {
                Text("📝 Pro tip:")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Text("Add your reasons to stay away so they show up here when you're weak. Future you will thank you.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                
                Button(action: {
                    Haptics.feedback(style: .medium)
                    showAddWhy = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                        Text("Add Your Why")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 40)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 20)
    }
    
    private var bottomButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                Haptics.feedback(style: .medium)
                showMeditate = true
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "wind")
                        .font(.system(size: 18, weight: .semibold))
                    Text("I Need To Breathe 🧘")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "00C7BE"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "00C7BE").opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            Button(action: {
                Haptics.feedback(style: .heavy)
                showRelapseConfirm = true
            }) {
                Text("I Relapsed 😔")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "FF3B30"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "FF3B30").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(Color(hex: "F9F9F9").opacity(0.98))
                .ignoresSafeArea()
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
        )
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            animateWarning = true
        }
        
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            pulseEmoji = true
        }
        
        withAnimation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
            shakeIntensity = 3
        }
        
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                currentQuoteIndex = (currentQuoteIndex + 1) % sosQuotes.count
            }
        }
    }
    
    private func saveImageToDocuments(_ image: UIImage) -> String? {
        guard let directory = documentsDirectory() else { return nil }
        let fileName = UUID().uuidString + ".jpg"
        let url = directory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        do {
            try data.write(to: url, options: .atomic)
            return fileName
        } catch {
            return nil
        }
    }
}

#Preview("With Whys") {
    PanicView()
        .environment(TrackingStore.previewLevel2WithProgress)
        .environment(NotificationStore())
        .modelContainer(for: [WhyItemRecord.self], inMemory: true)
}

#Preview("Empty State") {
    PanicView()
        .environment(TrackingStore.previewLevel2WithProgress)
        .environment(NotificationStore())
        .modelContainer(for: [WhyItemRecord.self], inMemory: true)
}
