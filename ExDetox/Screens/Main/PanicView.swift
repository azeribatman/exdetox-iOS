import SwiftUI
import SwiftData

struct PanicView: View {
    @Environment(\.dismiss) var dismiss
    @Query(sort: \WhyItemRecord.createdAt, order: .reverse) private var whyItems: [WhyItemRecord]
    @State private var showMeditate = false
    @State private var showCamera = false
    
    // Animation states
    @State private var animateText = false
    
    private func documentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    private func loadImage(from fileName: String) -> UIImage? {
        guard let directory = documentsDirectory() else { return nil }
        let url = directory.appendingPathComponent(fileName)
        return UIImage(contentsOfFile: url.path)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("SOS Mode 🚨")
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
            .padding(.bottom, 10)
            .background(Color(hex: "F9F9F9"))
            
            ScrollView {
                VStack(spacing: 24) {
                    if !whyItems.isEmpty {
                        // "My Whys" Content
                        VStack(spacing: 20) {
                            Text("NOOOO! DON'T DO IT! 🛑")
                                .font(.largeTitle)
                                .fontWeight(.black)
                                .foregroundStyle(.red)
                                .scaleEffect(animateText ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: animateText)
                            
                            Text("Remember why you started:")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            ForEach(whyItems) { item in
                                VStack(alignment: .leading, spacing: 12) {
                                    if let fileName = item.imageFileName, let uiImage = loadImage(from: fileName) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxHeight: 250)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .frame(maxWidth: .infinity)
                                    }
                                    
                                    Text(item.title)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(16)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                    } else {
                        // No Whys - Camera Case
                        VStack(spacing: 24) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                                .padding(30)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                            
                            Text("Capture the Pain")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("You haven't added any reasons yet. Take a photo or write down why you need to stay away.")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                            
                            Button(action: {
                                showCamera = true // Placeholder for camera action
                            }) {
                                Text("Open Camera 📸")
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal, 40)
                        }
                        .padding(.top, 40)
                    }
                }
                .padding(.bottom, 120) // Space for safe area buttons
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    Button(action: {
                        showMeditate = true
                    }) {
                        Text("I am thinking of relapsing 😨")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .teal.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    Button(action: {
                        // Handle Relapse logic here (e.g. reset progress)
                        // For now just dismiss or maybe we should add a reset callback
                        dismiss()
                    }) {
                        Text("I relapsed 😔")
                            .fontWeight(.bold)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(20)
                .background(
                    Rectangle()
                        .fill(Color(hex: "F9F9F9").opacity(0.95))
                        .ignoresSafeArea()
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
                )
            }
        }
        .background(Color(hex: "F9F9F9").ignoresSafeArea())
        .onAppear {
            animateText = true
        }
        .sheet(isPresented: $showMeditate) {
            MeditateView()
        }
        .sheet(isPresented: $showCamera) {
            // Placeholder for camera view or image picker
            VStack {
                Text("Camera Placeholder")
                Button("Close") { showCamera = false }
            }
        }
    }
}

#Preview("With Whys") {
    PanicView()
        .modelContainer(for: [WhyItemRecord.self], inMemory: true)
}

#Preview("Empty State") {
    PanicView()
        .modelContainer(for: [WhyItemRecord.self], inMemory: true)
}


