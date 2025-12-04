import SwiftUI

struct WhyItem: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String?
    // In a real app we'd store the image data or path. For demo we can store the Image if we want, or just pretend.
    // Let's modify this to support the demo flow better.
    let addedImage: Image? 
    let date: Date
    
    // Custom init for backward compatibility with mock data
    init(title: String, imageName: String? = nil, addedImage: Image? = nil, date: Date = Date()) {
        self.title = title
        self.imageName = imageName
        self.addedImage = addedImage
        self.date = date
    }
}

struct MyWhyView: View {
    // Mock Data
    @Binding var items: [WhyItem]
    @State private var showAddSheet = false
    @State private var showSettings = false
    
    // Default init for previews/mocking
    init(items: Binding<[WhyItem]>) {
        self._items = items
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
                let newItem = WhyItem(title: title, addedImage: image)
                withAnimation {
                    items.insert(newItem, at: 0)
                }
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
                    if let addedImage = item.addedImage {
                        // User uploaded image
                        addedImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .frame(maxWidth: .infinity)
                    } else if let imageName = item.imageName {
                        // Mock image
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .aspectRatio(16/9, contentMode: .fit)
                            .overlay(
                                Image(systemName: imageName)
                                    .font(.largeTitle)
                                    .foregroundStyle(.gray.opacity(0.5))
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Text(item.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(nil) // Allow full text
                        .fixedSize(horizontal: false, vertical: true)
                        
                    Text(item.date.formatted(date: .abbreviated, time: .shortened))
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
    MyWhyView(items: .constant([]))
}

#Preview("Filled State") {
    // Let's create a version with initial items for preview purposes
    MyWhyView(items: .constant([
        WhyItem(title: "He never listened to me when I was crying."),
        WhyItem(title: "Forgot my birthday... again.", imageName: "photo"),
        WhyItem(title: "Gaslighting 101.")
    ]))
}

