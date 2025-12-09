import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showResetAlert = false
    
    var body: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        accountSection
                        legalSection
                        socialSection
                        supportSection
                        
                        versionFooter
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .alert("Reset Progress", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                Haptics.notification(type: .warning)
            }
        } message: {
            Text("This will erase all your progress. This action cannot be undone.")
        }
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("SETTINGS")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundColor(.secondary)
                
                Text("Your space.")
                    .font(.system(size: 28, weight: .black, design: .rounded))
            }
            
            Spacer()
            
            Button(action: {
                Haptics.feedback(style: .light)
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private var accountSection: some View {
        SettingsSection(title: "ACCOUNT") {
            SettingsRow(
                icon: "arrow.counterclockwise",
                title: "Reset Progress",
                subtitle: "Start fresh",
                iconColor: .red
            ) {
                Haptics.feedback(style: .medium)
                showResetAlert = true
            }
            
            SettingsDivider()
            
            SettingsRow(
                icon: "shield.lefthalf.filled",
                title: "Content Blocking",
                subtitle: "Safari protection",
                iconColor: .blue
            ) {
                Haptics.feedback(style: .light)
            }
        }
    }
    
    private var legalSection: some View {
        SettingsSection(title: "LEGAL") {
            SettingsRow(
                icon: "hand.raised.fill",
                title: "Privacy Policy",
                iconColor: .gray
            ) {
                Haptics.feedback(style: .light)
            }
            
            SettingsDivider()
            
            SettingsRow(
                icon: "doc.text.fill",
                title: "Terms of Use",
                iconColor: .gray
            ) {
                Haptics.feedback(style: .light)
            }
        }
    }
    
    private var socialSection: some View {
        SettingsSection(title: "FOLLOW US") {
            SettingsRow(
                icon: "play.rectangle.fill",
                title: "TikTok",
                subtitle: "@exdetox",
                iconColor: .black
            ) {
                Haptics.feedback(style: .light)
            }
            
            SettingsDivider()
            
            SettingsRow(
                icon: "camera.fill",
                title: "Instagram",
                subtitle: "@exdetox",
                iconColor: .pink
            ) {
                Haptics.feedback(style: .light)
            }
        }
    }
    
    private var supportSection: some View {
        SettingsSection(title: "SUPPORT") {
            SettingsRow(
                icon: "star.fill",
                title: "Rate ExDetox",
                subtitle: "Help others heal",
                iconColor: .yellow
            ) {
                Haptics.feedback(style: .medium)
            }
            
            SettingsDivider()
            
            SettingsRow(
                icon: "envelope.fill",
                title: "Contact Us",
                subtitle: "We're here for you",
                iconColor: .purple
            ) {
                Haptics.feedback(style: .light)
            }
        }
    }
    
    private var versionFooter: some View {
        VStack(spacing: 8) {
            Text("ExDetox")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
            
            Text("Version 1.0.0")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.tertiary)
            
            Text("Made with 🫀 for the heartbroken")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.tertiary)
                .padding(.top, 4)
        }
        .padding(.top, 24)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.5)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
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
        .buttonStyle(SettingsRowButtonStyle())
    }
}

struct SettingsRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.black.opacity(0.03) : Color.clear)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SettingsDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.black.opacity(0.05))
            .frame(height: 1)
            .padding(.leading, 68)
    }
}

#Preview {
    SettingsView()
}
