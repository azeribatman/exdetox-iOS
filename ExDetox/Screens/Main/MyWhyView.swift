import SwiftUI
import SwiftData

struct MyWhyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WhyItemRecord.createdAt, order: .reverse) private var items: [WhyItemRecord]
    @State private var showAddSheet = false
    @State private var showSettings = false
    
    private let creamBg = Color(hex: "F5F0E8")
    private let cardBg = Color(hex: "FFFDF9")
    
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
            headerView
            
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .top) {
                    GeometryReader { geometry in
                        let minY = geometry.frame(in: .global).minY
                        if minY > 150 {
                            HStack(spacing: 6) {
                                Text("👀")
                                Text("Don't look back!")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.red)
                            }
                            .frame(maxWidth: .infinity)
                            .offset(y: -minY + 60)
                            .opacity(min(1.0, (Double(minY) - 150.0) / 50.0))
                        }
                    }
                    .frame(height: 0)
                    .zIndex(1)
                    
                    VStack(spacing: 16) {
                        if items.isEmpty {
                            emptyStateView
                        } else {
                            filledStateView
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .background(creamBg.ignoresSafeArea())
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
    
    private var headerView: some View {
        HStack(alignment: .center) {
            Text("My Why")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Button(action: {
                showAddSheet = true
                Haptics.feedback(style: .light)
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 40, height: 40)
                    .background(cardBg)
                    .clipShape(Circle())
            }
            
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 40, height: 40)
                    .background(cardBg)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 60)
            
            Text("🚩")
                .font(.system(size: 56))
                .frame(width: 100, height: 100)
                .background(Color.red.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 10) {
                Text("Why did it end?")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                
                Text("Document the red flags and reasons.\nRead this when you're feeling weak.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
            }
            
            Button(action: {
                showAddSheet = true
                Haptics.feedback(style: .medium)
            }) {
                Text("Add Your First Reason")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    private var filledStateView: some View {
        VStack(spacing: 12) {
            ForEach(items) { item in
                whyItemCard(item)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }
    
    private func whyItemCard(_ item: WhyItemRecord) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let fileName = item.imageFileName, let uiImage = loadImage(from: fileName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .frame(maxWidth: .infinity)
            }
            
            Text(item.title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                
            Text(item.createdAt.formatted(date: .abbreviated, time: .omitted))
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
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

