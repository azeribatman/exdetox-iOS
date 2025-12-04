import SwiftUI

struct NotificationBannerView: View {
    @Environment(NotificationStore.self) private var notificationStore
    
    var body: some View {
        if let notification = notificationStore.current {
            HStack(alignment: .top, spacing: 12) {
                Text(leadingSymbol(for: notification.kind))
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text(notification.message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Button {
                    notificationStore.dismissCurrent()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .padding(6)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
    
    private func leadingSymbol(for kind: AppNotificationKind) -> String {
        switch kind {
        case .dailyCheckIn:
            return "🧠"
        case .challenge:
            return "⚡️"
        case .levelUp(let level):
            return level.emoji
        case .relapseSupport:
            return "💔"
        case .custom:
            return "✨"
        }
    }
}

#Preview {
    let notificationStore = NotificationStore()
    notificationStore.showDailyCheckIn()
    
    return ZStack {
        Color(hex: "F9F9F9").ignoresSafeArea()
        VStack {
            NotificationBannerView()
            Spacer()
        }
    }
    .environment(notificationStore)
}


