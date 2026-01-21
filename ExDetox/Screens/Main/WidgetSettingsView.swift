import SwiftUI
import WidgetKit

struct WidgetSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var settings: WidgetSettings = WidgetDataManager.shared.getWidgetSettings()
    @State private var selectedBackgroundIndex = 0
    @State private var selectedAccentIndex = 0
    
    let backgroundColors: [(name: String, hex: String)] = [
        ("White", "FFFFFF"),
        ("Cream", "FFF8F0"),
        ("Pink", "FFF0F5"),
        ("Lavender", "F5F0FF"),
        ("Mint", "F0FFF5"),
        ("Sky", "F0F8FF")
    ]
    
    let accentColors: [(name: String, hex: String)] = [
        ("Black", "000000"),
        ("Coral", "FF6B6B"),
        ("Purple", "8B5CF6"),
        ("Blue", "3B82F6"),
        ("Green", "22C55E"),
        ("Pink", "EC4899")
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Preview
                        widgetPreview
                        
                        // Background Color
                        colorSection(
                            title: "Background",
                            colors: backgroundColors,
                            selectedIndex: $selectedBackgroundIndex
                        ) { index in
                            settings.backgroundColor = backgroundColors[index].hex
                            saveSettings()
                        }
                        
                        // Accent Color
                        colorSection(
                            title: "Text Color",
                            colors: accentColors,
                            selectedIndex: $selectedAccentIndex
                        ) { index in
                            settings.accentColor = accentColors[index].hex
                            saveSettings()
                        }
                        
                        // Instructions
                        instructionsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            loadCurrentSettings()
        }
    }
    
    private var header: some View {
        HStack {
            Text("Widget Style")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
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
    
    private var widgetPreview: some View {
        HStack(spacing: 16) {
            // Small widget preview
            smallWidgetPreview
            
            // Lock screen preview
            lockScreenPreview
        }
    }
    
    private var smallWidgetPreview: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(hex: settings.backgroundColor))
                    .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
                
                VStack(spacing: 0) {
                    Text("ExDetox")
                        .font(.system(size: 8, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: settings.accentColor).opacity(0.4))
                    
                    Spacer()
                    
                    Text("7")
                        .font(.system(size: 36, weight: .regular, design: .serif))
                        .foregroundStyle(Color(hex: settings.accentColor))
                    
                    Text("days")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: settings.accentColor).opacity(0.4))
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    Spacer()
                    
                    Text("Be Proud")
                        .font(.system(size: 7, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: settings.accentColor).opacity(0.3))
                        .italic()
                }
                .padding(10)
            }
            .frame(width: 140, height: 140)
            
            Text("Home Screen")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
    
    private var lockScreenPreview: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(hex: "2C2C2E"))
                    .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
                
                // Lock screen rectangular widget preview - serif style
                HStack(spacing: 0) {
                    VStack(spacing: -1) {
                        Text("7")
                            .font(.system(size: 22, weight: .regular, design: .serif))
                            .foregroundStyle(.white)
                        Text("days")
                            .font(.system(size: 6, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                            .textCase(.uppercase)
                            .tracking(1)
                    }
                    .frame(width: 36)
                    
                    Rectangle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 1, height: 28)
                        .padding(.horizontal, 6)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("ExDetox")
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Be Proud")
                            .font(.system(size: 7, weight: .regular, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                            .italic()
                    }
                }
                .padding(.horizontal, 14)
            }
            .frame(width: 140, height: 140)
            
            Text("Lock Screen")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
    
    private func colorSection(
        title: String,
        colors: [(name: String, hex: String)],
        selectedIndex: Binding<Int>,
        onSelect: @escaping (Int) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                    Button(action: {
                        Haptics.feedback(style: .light)
                        selectedIndex.wrappedValue = index
                        onSelect(index)
                    }) {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: color.hex))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                    )
                                
                                if selectedIndex.wrappedValue == index {
                                    Circle()
                                        .stroke(Color.black, lineWidth: 3)
                                        .frame(width: 58, height: 58)
                                    
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(color.hex == "FFFFFF" || color.hex == "FFF8F0" || color.hex == "FFF0F5" || color.hex == "F5F0FF" || color.hex == "F0FFF5" || color.hex == "F0F8FF" ? .black : .white)
                                }
                            }
                            
                            Text(color.name)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
            )
        }
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How to Add")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
            
            VStack(spacing: 0) {
                instructionRow(
                    title: "Home Screen",
                    description: "Long press home → + → ExDetox"
                )
                
                Divider().padding(.leading, 16)
                
                instructionRow(
                    title: "Lock Screen",
                    description: "Long press lock screen → Customize"
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
            )
        }
    }
    
    private func instructionRow(title: String, description: String) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                
                Text(description)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
    }
    
    private func loadCurrentSettings() {
        settings = WidgetDataManager.shared.getWidgetSettings()
        
        if let bgIndex = backgroundColors.firstIndex(where: { $0.hex == settings.backgroundColor }) {
            selectedBackgroundIndex = bgIndex
        }
        
        if let accentIndex = accentColors.firstIndex(where: { $0.hex == settings.accentColor }) {
            selectedAccentIndex = accentIndex
        }
    }
    
    private func saveSettings() {
        WidgetDataManager.shared.updateWidgetSettings(settings)
    }
}

#Preview {
    WidgetSettingsView()
}
