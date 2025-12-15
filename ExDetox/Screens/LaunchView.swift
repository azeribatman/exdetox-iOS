import Foundation
import SwiftUI
import SuperwallKit

struct LaunchView: View {
    @Environment(Router.self) private var router
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(\.modelContext) private var modelContext
    
    @State private var ghostAppeared = false
    @State private var ghostFloating = false
    @State private var heartBeat = false
    @State private var heartFloatIn = false
    @State private var showGlow = false
    @State private var showText = false
    @State private var showTagline = false
    @State private var particlesVisible = false
    @State private var gradientRotation: Double = 0
    
    private let pastelGradient = LinearGradient(
        colors: [
            Color(hex: "FFB6C1"),
            Color(hex: "E6E6FA"),
            Color(hex: "B0E0E6"),
            Color(hex: "98FB98"),
            Color(hex: "FFFACD"),
            Color(hex: "FFB6C1")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            Color(hex: "FEFEFE").ignoresSafeArea()
            
            animatedBackground
            
            floatingParticles
            
            VStack(spacing: 0) {
                ZStack {
                    if showGlow {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "FFB6C1").opacity(0.4),
                                        Color(hex: "E6E6FA").opacity(0.2),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 50,
                                    endRadius: 150
                                )
                            )
                            .frame(width: 300, height: 300)
                            .blur(radius: 20)
                            .scaleEffect(heartBeat ? 1.1 : 1.0)
                    }
                    
                    ZStack {
                        Image("common.appicon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 160, height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
                            .scaleEffect(ghostAppeared ? 1 : 0.3)
                            .opacity(ghostAppeared ? 1 : 0)
                            .offset(y: ghostFloating ? -8 : 8)
                            .rotationEffect(.degrees(ghostFloating ? -2 : 2))
                    }
                }
                .frame(height: 200)
                
                VStack(spacing: 12) {
                    Text("exdetox")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "2D2D2D"), Color(hex: "4A4A4A")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(showText ? 1 : 0)
                        .offset(y: showText ? 0 : 30)
                    
                    Text("your healing starts here ✨")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "888888"))
                        .opacity(showTagline ? 1 : 0)
                        .offset(y: showTagline ? 0 : 15)
                }
                .padding(.top, 16)
            }
        }
        .onAppear {
            startAnimationSequence()
        }
    }
    
    private var animatedBackground: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "FFB6C1").opacity(0.15),
                                Color(hex: "E6E6FA").opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 300 + CGFloat(index * 100), height: 300 + CGFloat(index * 100))
                    .offset(
                        x: CGFloat.random(in: -100...100),
                        y: CGFloat.random(in: -200...200)
                    )
                    .blur(radius: 60)
                    .opacity(showGlow ? 0.8 : 0)
            }
        }
    }
    
    private var floatingParticles: some View {
        ZStack {
            ForEach(0..<12) { index in
                FloatingHeartParticle(
                    delay: Double(index) * 0.15,
                    isVisible: particlesVisible
                )
            }
        }
    }
    
    private func startAnimationSequence() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            ghostAppeared = true
            showGlow = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                ghostFloating = true
            }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                heartBeat = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showText = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.easeOut(duration: 0.25)) {
                showTagline = true
            }
            particlesVisible = true
        }
        
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            await MainActor.run {
                if userProfileStore.hasCompletedOnboarding {
                    TrackingPersistence.bootstrap(store: trackingStore, context: modelContext)
                    
                    if trackingStore.state.exName.isEmpty {
                        trackingStore.state.exName = userProfileStore.profile.exName
                    }
                    
                    Superwall.shared.register(
                        placement: "app_launch_onboarded"
                    ) {
                        router.set(.main)
                    }
                } else {
                    router.set(.onboarding1)
                }
            }
        }
    }
}

struct FloatingHeartParticle: View {
    let delay: Double
    let isVisible: Bool
    
    @State private var animate = false
    @State private var appeared = false
    
    private let startX = CGFloat.random(in: -180...180)
    private let startY = CGFloat.random(in: 200...350)
    private let size = CGFloat.random(in: 8...16)
    private let duration = Double.random(in: 3...5)
    private let horizontalDrift = CGFloat.random(in: -30...30)
    
    private let particleColors: [Color] = [
        Color(hex: "FFB6C1"),
        Color(hex: "E6E6FA"),
        Color(hex: "B0E0E6"),
        Color(hex: "98FB98"),
        Color(hex: "FFFACD"),
        Color(hex: "FFC0CB")
    ]
    
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: size))
            .foregroundStyle(particleColors.randomElement() ?? .pink)
            .opacity(appeared ? (animate ? 0 : 0.7) : 0)
            .offset(
                x: startX + (animate ? horizontalDrift : 0),
                y: animate ? -400 : startY
            )
            .scaleEffect(animate ? 0.3 : 1)
            .onAppear {
                guard isVisible else { return }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    appeared = true
                    withAnimation(
                        .easeOut(duration: duration)
                        .repeatForever(autoreverses: false)
                    ) {
                        animate = true
                    }
                }
            }
            .onChange(of: isVisible) { _, newValue in
                if newValue && !appeared {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        appeared = true
                        withAnimation(
                            .easeOut(duration: duration)
                            .repeatForever(autoreverses: false)
                        ) {
                            animate = true
                        }
                    }
                }
            }
    }
}

#Preview {
    LaunchView()
        .environment(Router.base)
        .environment(UserProfileStore())
        .environment(TrackingStore())
}
