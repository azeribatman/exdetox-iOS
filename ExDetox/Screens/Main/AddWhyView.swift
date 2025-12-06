import SwiftUI
import PhotosUI

struct AddWhyView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    var onSave: (String, UIImage?) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Text("New Entry")
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
                .padding(.top, 20)
                .padding(.bottom, 20) // Added padding bottom to separate from scroll view
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Title Input
                        TextField("What happened?", text: $title, axis: .vertical)
                            .font(.title3)
                            .padding(.vertical, 12) // Only vertical padding
                            .background(Color.clear) // Explicit clear background
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color.gray.opacity(0.2)),
                                alignment: .bottom
                            )
                        
                        // Image Picker
                        if let selectedImage {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                Button(action: {
                                    self.selectedImage = nil
                                    self.selectedItem = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title)
                                        .foregroundStyle(.white)
                                        .shadow(radius: 2)
                                }
                                .padding(8)
                            }
                        } else {
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                HStack {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.title2)
                                    Text("Add Evidence")
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(.primary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                        .foregroundStyle(Color.secondary.opacity(0.5))
                                )
                            }
                        }
                        
                        Spacer()
                        
                        // Save Button
                        Button(action: {
                            if !title.isEmpty {
                                onSave(title, selectedImage)
                                dismiss()
                            }
                        }) {
                            Text("Save Reason")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(title.isEmpty ? Color.gray : Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(title.isEmpty)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(Color.white.ignoresSafeArea())
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                }
            }
        }
    }
}

#Preview {
    AddWhyView(onSave: { _, _ in })
}

