import Foundation
import SwiftUI
import SuperwallKit

struct LaunchView: View {
    @Environment(Router.self) private var router
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(\.modelContext) private var modelContext
    
    @State private var showLogo = false
    @State private var showTagline = false
    
    var body: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "heart.slash.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(colors: [.pink, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .scaleEffect(showLogo ? 1 : 0.5)
                    .opacity(showLogo ? 1 : 0)
                
                VStack(spacing: 8) {
                    Text("ExDetox")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    
                    Text("Your healing starts here")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .opacity(showTagline ? 1 : 0)
                .offset(y: showTagline ? 0 : 20)
            }

        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showLogo = true
            }
            
            withAnimation(.easeOut.delay(0.3)) {
                showTagline = true
            }
            
            Task {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                
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
}

#Preview {
    LaunchView()
        .environment(Router.base)
        .environment(UserProfileStore())
        .environment(TrackingStore())
}
