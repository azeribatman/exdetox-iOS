import SwiftUI
import SwiftData

struct MyWhyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WhyItemRecord.createdAt, order: .reverse) private var items: [WhyItemRecord]
    @State private var showAddSheet = false
    @State private var showSettings = false
    
    private func documentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    private func saveImageToDocuments(_ image: UIImage) -> String? {
        guard let directory = documentsDirectory() else { return nil }
        let fileName = UUID().uuidString + ".jpg"
        let url = directory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        do {
            try data.write(to: url, options: .atomic)
            return fileName
        } catch {
            return nil
        }
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
                Text("My Why")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                // Add Button
                Button(action: {
                    showAddSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundStyle(.black)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                .padding(.trailing, 8)
                
                // Settings Button
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.black)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
            }
            .frame(height: 62)
            .padding(.horizontal, 20)
            .background(Color(hex: "F9F9F9"))
            
            ScrollView {
                ZStack(alignment: .top) {
                    // Easter Egg
                    GeometryReader { geometry in
                        let minY = geometry.frame(in: .global).minY
                        if minY > 150 { // Threshold for showing the easter egg
                            HStack(spacing: 8) {
                                Text("I see you looking back... 👀")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.secondary)
                                Text("Don't do it!")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.red)
                            }
                            .frame(maxWidth: .infinity)
                            .offset(y: -minY + 60) // Keep it positioned visibly
                            .opacity(min(1.0, (Double(minY) - 150.0) / 50.0)) // Fade in
                        }
                    }
                    .frame(height: 0) // Don't take up space in layout
                    .zIndex(1)
                    
                    VStack(spacing: 24) {
                        if items.isEmpty {
                            emptyStateView
                        } else {
                            filledStateView
                        }
                    }
                    .padding(.top, 24)
                }
            }
        }
        .background(Color(hex: "F9F9F9").ignoresSafeArea())
        .sheet(isPresented: $showAddSheet) {
            AddWhyView { title, image in
                var fileName: String?
                if let image {
                    fileName = saveImageToDocuments(image)
                }
                let newItem = WhyItemRecord(title: title, imageFileName: fileName)
                modelContext.insert(newItem)
                try? modelContext.save()
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 40)
            
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 160, height: 160)
                
                Image(systemName: "heart.slash.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.gray.opacity(0.5))
            }
            .padding(.bottom, 10)
            
            VStack(spacing: 12) {
                Text("Why did it end?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("Document the red flags, the bad moments, and the reasons you left. Read this when you're feeling weak.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                showAddSheet = true
            }) {
                Text("Add Your First Reason")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            Spacer()
        }
    }
    
    var filledStateView: some View {
        VStack(spacing: 16) {
            ForEach(items) { item in
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
                        .lineLimit(nil) // Allow full text
                        .fixedSize(horizontal: false, vertical: true)
                        
                    Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Fill width
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

#Preview {
    MyWhyView()
        .modelContainer(for: [WhyItemRecord.self], inMemory: true)
}

#Preview("Filled State") {
    MyWhyView()
        .modelContainer(for: [WhyItemRecord.self], inMemory: true)
}

