import SwiftUI

struct OnboardingNotificationView: View {
    @Environment(Router.self) private var router
    @Environment(UserProfileStore.self) private var userProfileStore
    
    @State private var phase = 0
    @State private var bellScale: CGFloat = 0
    @State private var bellRotation: Double = 0
    @State private var ringOpacity: Double = 0
    @State private var ring2Opacity: Double = 0
    @State private var ring3Opacity: Double = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var ring2Scale: CGFloat = 0.5
    @State private var ring3Scale: CGFloat = 0.5
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showFeatures = false
    @State private var showButton = false
    @State private var floatOffset: CGFloat = 0
    @State private var isRequesting = false
    
    @State private var mockNotification1Offset: CGFloat = -300
    @State private var mockNotification2Offset: CGFloat = -300
    @State private var mockNotification1Opacity: Double = 0
    @State private var mockNotification2Opacity: Double = 0
    
    private let notificationManager = LocalNotificationManager.shared
    
    var body: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                bellSection
                
                Spacer().frame(height: 40)
                
                textSection
                
                Spacer().frame(height: 32)
                
                if showFeatures {
                    featuresSection
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer()
                Spacer()
                
                buttonSection
            }
            .padding(.horizontal, 24)
            
            mockNotificationsOverlay
        }
        .onAppear {
            startAnimationSequence()
            startFloating()
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .disableSwipeGesture()
    }
    
    private var bellSection: some View {
        ZStack {
            Circle()
                .stroke(Color.black.opacity(0.06), lineWidth: 2)
                .frame(width: 180, height: 180)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)
            
            Circle()
                .stroke(Color.black.opacity(0.04), lineWidth: 1.5)
                .frame(width: 240, height: 240)
                .scaleEffect(ring2Scale)
                .opacity(ring2Opacity)
            
            Circle()
                .stroke(Color.black.opacity(0.02), lineWidth: 1)
                .frame(width: 300, height: 300)
                .scaleEffect(ring3Scale)
                .opacity(ring3Opacity)
            
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 140, height: 140)
                    .shadow(color: .black.opacity(0.08), radius: 24, y: 10)
                
                Text("🔔")
                    .font(.system(size: 64))
                    .rotationEffect(.degrees(bellRotation))
            }
            .scaleEffect(bellScale)
            .offset(y: floatOffset)
        }
    }
    
    private var textSection: some View {
        VStack(spacing: 16) {
            if showTitle {
                Text("Stay on track")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            if showSubtitle {
                Text("We'll send you gentle reminders to help you resist the urge and celebrate your wins.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .transition(.opacity)
            }
        }
    }
    
    private var featuresSection: some View {
        VStack(spacing: 12) {
            featureRow(
                icon: "shield.checkered",
                iconColor: Color(hex: "FF6B6B"),
                title: "Decode Their Messages",
                subtitle: "See through manipulation tactics"
            )
            
            featureRow(
                icon: "flame.fill",
                iconColor: Color(hex: "FF9500"),
                title: "Celebrate Streaks",
                subtitle: "Get hyped for every milestone"
            )
        }
        .padding(.horizontal, 8)
    }
    
    private func featureRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
        )
    }
    
    private var buttonSection: some View {
        VStack(spacing: 16) {
            if showButton {
                Button(action: requestNotificationPermission) {
                    HStack(spacing: 10) {
                        if isRequesting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Enable Notifications")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
                }
                .disabled(isRequesting)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                
                Button(action: skipNotifications) {
                    Text("Maybe later")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .transition(.opacity)
            }
        }
        .padding(.bottom, 50)
    }
    
    private var mockNotificationsOverlay: some View {
        VStack {
            mockNotificationBanner(
                icon: "🚨",
                title: userProfileStore.profile.exName.isEmpty ? "Ex" : userProfileStore.profile.exName,
                message: "I miss you..."
            )
            .offset(y: mockNotification1Offset)
            .opacity(mockNotification1Opacity)
            
            mockNotificationBanner(
                icon: "🔥",
                title: "7 Day Streak!",
                message: "You're on fire! Keep going 💪"
            )
            .offset(y: mockNotification2Offset)
            .opacity(mockNotification2Opacity)
            
            Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal, 16)
    }
    
    private func mockNotificationBanner(icon: String, title: String, message: String) -> some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    
                    Spacer()
                    
                    Text("now")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Text(message)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        )
    }
    
    private func startFloating() {
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            floatOffset = 12
        }
    }
    
    private func startAnimationSequence() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            bellScale = 1.0
        }
        Haptics.feedback(style: .medium)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                bellRotation = 15
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    bellRotation = -15
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    bellRotation = 10
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    bellRotation = 0
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.8)) {
                ringOpacity = 1
                ringScale = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeOut(duration: 0.8)) {
                ring2Opacity = 1
                ring2Scale = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeOut(duration: 0.8)) {
                ring3Opacity = 1
                ring3Scale = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showTitle = true
            }
            Haptics.feedback(style: .light)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeOut(duration: 0.5)) {
                showSubtitle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showFeatures = true
            }
            Haptics.feedback(style: .light)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showButton = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            showMockNotifications()
        }
    }
    
    private func showMockNotifications() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            mockNotification1Offset = 0
            mockNotification1Opacity = 1
        }
        Haptics.feedback(style: .light)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                mockNotification2Offset = 0
                mockNotification2Opacity = 1
            }
            Haptics.feedback(style: .light)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                mockNotification1Opacity = 0
                mockNotification2Opacity = 0
            }
        }
    }
    
    private func requestNotificationPermission() {
        isRequesting = true
        Haptics.feedback(style: .medium)
        
        Task {
            let granted = await notificationManager.requestAuthorization()
            
            await MainActor.run {
                userProfileStore.profile.notificationPreferences.notificationPermissionRequested = true
                userProfileStore.profile.notificationPreferences.exQuizEnabled = granted
                userProfileStore.profile.notificationPreferences.streakCelebrationEnabled = granted
                
                isRequesting = false
                
                // Track notification response
                AnalyticsManager.shared.trackOnboardingNotificationResponse(enabled: granted)
                
                if granted {
                    Haptics.notification(type: .success)
                }
                
                navigateToNext()
            }
        }
    }
    
    private func skipNotifications() {
        Haptics.feedback(style: .light)
        userProfileStore.profile.notificationPreferences.notificationPermissionRequested = true
        userProfileStore.profile.notificationPreferences.exQuizEnabled = false
        userProfileStore.profile.notificationPreferences.streakCelebrationEnabled = false
        
        // Track notification skipped
        AnalyticsManager.shared.trackOnboardingNotificationResponse(enabled: false)
        
        navigateToNext()
    }
    
    private func navigateToNext() {
        router.navigate(.onboarding5)
    }
}

#Preview {
    OnboardingNotificationView()
        .environment(Router())
        .environment(UserProfileStore())
}
