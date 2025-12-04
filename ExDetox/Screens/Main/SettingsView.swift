import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(Color(hex: "F9F9F9"))
            
            ScrollView {
                VStack(spacing: 24) {
                    // Group 1: Progress & Blocking
                    VStack(spacing: 0) {
                        settingsRow(title: "Reset Progress", icon: "arrow.counterclockwise", color: .red)
                        Divider().padding(.leading, 54)
                        settingsRow(title: "Content Blocking", icon: "shield.fill", color: .blue)
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Group 2: Legal
                    VStack(spacing: 0) {
                        settingsRow(title: "Privacy Policy", icon: "hand.raised.fill", color: .gray)
                        Divider().padding(.leading, 54)
                        settingsRow(title: "Terms of Use", icon: "doc.text.fill", color: .gray)
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Group 3: Social
                    VStack(spacing: 0) {
                        settingsRow(title: "TikTok", icon: "play.rectangle.fill", color: .black)
                        Divider().padding(.leading, 54)
                        settingsRow(title: "Instagram", icon: "camera.fill", color: .pink)
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Group 4: Rating
                    VStack(spacing: 0) {
                        settingsRow(title: "Rate Us", icon: "star.fill", color: .yellow)
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .padding(20)
            }
        }
        .background(Color(hex: "F9F9F9").ignoresSafeArea())
    }
    
    @ViewBuilder
    func settingsRow(title: String, icon: String, color: Color) -> some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
        }
    }
}

#Preview {
    SettingsView()
}


