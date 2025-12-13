import SwiftUI
import SwiftData
import SuperwallKit

struct OnboardingView4: View {
    @Environment(Router.self) private var router
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(\.modelContext) private var modelContext
    
    @State private var phase = 0
    @State private var userCount = 0
    
    let reviews = [
        ("Sarah K.", "Finally stopped stalking. This actually works.", "🙏"),
        ("Mike T.", "Haven't texted her in 3 weeks. New record.", "💪"),
        ("Jessica L.", "My glow up is REAL.", "✨"),
        ("David R.", "Better than therapy honestly.", "🔥"),
        ("Emily W.", "I feel like myself again.", "❤️‍🩹")
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        VStack(spacing: 24) {
                            if phase >= 1 {
                                Text("Your plan\nis ready.")
                                    .font(.system(size: 42, weight: .black, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                            
                            if phase >= 2 {
                                HStack(spacing: 16) {
                                    Image(systemName: "laurel.leading")
                                        .font(.system(size: 36))
                                        .foregroundColor(.orange)
                                    
                                    VStack(spacing: 2) {
                                        Text("\(userCount, format: .number)+")
                                            .font(.system(size: 28, weight: .black, design: .rounded))
                                            .monospacedDigit()
                                            .contentTransition(.numericText(value: Double(userCount)))
                                        Text("healed")
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundStyle(.secondary)
                                            .textCase(.uppercase)
                                            .tracking(2)
                                    }
                                    
                                    Image(systemName: "laurel.trailing")
                                        .font(.system(size: 36))
                                        .foregroundColor(.orange)
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.top, 50)
                        
                        if phase >= 3 {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("REAL STORIES")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .tracking(2)
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 4)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 14) {
                                        ForEach(Array(reviews.enumerated()), id: \.offset) { index, review in
                                            ReviewCardNew(name: review.0, text: review.1, emoji: review.2)
                                                .transition(.asymmetric(
                                                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                                                    removal: .opacity
                                                ))
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                            .padding(.horizontal, 20)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                        
                        if phase >= 4 {
                            VStack(spacing: 16) {
                                Text("INCLUDES")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .tracking(2)
                                    .foregroundStyle(.secondary)
                                
                                VStack(spacing: 0) {
                                    PlanFeatureRow(icon: "brain.head.profile", title: "AI Coach", subtitle: "24/7 support", color: .indigo)
                                    Divider().padding(.leading, 60)
                                    PlanFeatureRow(icon: "heart.slash.fill", title: "No-Contact Tracker", subtitle: "Stay strong", color: .pink)
                                    Divider().padding(.leading, 60)
                                    PlanFeatureRow(icon: "sparkles", title: "Daily Tasks", subtitle: "Focus on you", color: .orange)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.06), radius: 16, y: 6)
                                )
                            }
                            .padding(.horizontal, 24)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
                
                Spacer()
                
                if phase >= 5 {
                    Button(action: {
                        Haptics.notification(type: .success)
                        completeOnboarding()
                    }) {
                        Text("Begin Healing")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    Color.clear.frame(height: 86)
                }
            }
        }
        .onAppear {
            runSequence()
            Haptics.feedback(style: .light)
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .disableSwipeGesture()
    }
    
    private func runSequence() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { phase = 1 }
        Haptics.feedback(style: .medium)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { phase = 2 }
            animateUserCount()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { phase = 3 }
            Haptics.feedback(style: .light)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { phase = 4 }
            Haptics.feedback(style: .light)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { phase = 5 }
        }
    }
    
    private func animateUserCount() {
        let target = 100000
        let duration: TimeInterval = 1.5
        let steps = 40
        let stepDuration = duration / Double(steps)
        
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDuration) {
                let progress = Double(i) / Double(steps)
                let eased = 1 - pow(1 - progress, 3)
                withAnimation(.linear(duration: stepDuration)) {
                    userCount = Int(eased * Double(target))
                }
            }
        }
    }
    
    private func completeOnboarding() {
        userProfileStore.completeOnboarding()
        
        let now = Date()
        trackingStore.state.exName = userProfileStore.profile.exName
        trackingStore.state.programStartDate = now
        trackingStore.state.levelStartDate = now
        trackingStore.state.noContactStartDate = now
        
        let profile = userProfileStore.profile
        trackingStore.recordDailyCheckIn(
            mood: profile.initialMoodScore,
            urge: profile.initialUrgeScore,
            note: "Initial check-in from onboarding"
        )
        
        TrackingPersistence.bootstrap(store: trackingStore, context: modelContext, isNewUser: true)
        
        Superwall.shared.register(placement: "onboarding_custom_plan") {
            router.set(.main)
        }
    }
}

struct ReviewCardNew: View {
    let name: String
    let text: String
    let emoji: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 2) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                }
            }
            
            Text(text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .lineLimit(3)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 18))
                
                Text(name)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.blue)
            }
        }
        .padding(16)
        .frame(width: 200, height: 140)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        )
    }
}

struct PlanFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    @State private var showCheck = false
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 42, height: 42)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "22C55E"))
                .scaleEffect(showCheck ? 1 : 0.01)
                .opacity(showCheck ? 1 : 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.3)) {
                showCheck = true
            }
            Haptics.feedback(style: .light)
        }
    }
}

#Preview {
    OnboardingView4()
        .environment(Router.base)
        .environment(UserProfileStore())
        .environment(TrackingStore())
}
