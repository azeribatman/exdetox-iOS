import SwiftUI
import PhotosUI

struct AddWhyView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @FocusState private var isFocused: Bool
    
    private let creamBg = Color(hex: "F5F0E8")
    private let cardBg = Color(hex: "FFFDF9")
    
    var onSave: (String, UIImage?) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    textInputCard
                    imagePickerCard
                    Spacer().frame(height: 20)
                    saveButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .background(creamBg.ignoresSafeArea())
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Add Reason")
                .font(.system(size: 20, weight: .bold, design: .rounded))
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.primary.opacity(0.5))
                    .frame(width: 32, height: 32)
                    .background(cardBg)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    private var textInputCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What happened?")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            
            TextField("Describe the red flag or bad moment...", text: $title, axis: .vertical)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .focused($isFocused)
                .lineLimit(3...8)
        }
        .padding(16)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var imagePickerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Evidence (Optional)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            
            if let selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            self.selectedImage = nil
                            self.selectedItem = nil
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4)
                    }
                    .padding(10)
                }
            } else {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    HStack(spacing: 10) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Add Photo")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(.primary.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .foregroundStyle(Color.primary.opacity(0.15))
                    )
                }
            }
        }
        .padding(16)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var saveButton: some View {
        Button(action: {
            if !title.isEmpty {
                Haptics.feedback(style: .medium)
                onSave(title, selectedImage)
                dismiss()
            }
        }) {
            Text("Save Reason")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(title.isEmpty ? Color.black.opacity(0.3) : Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(title.isEmpty)
    }
}

#Preview {
    AddWhyView(onSave: { _, _ in })
}

