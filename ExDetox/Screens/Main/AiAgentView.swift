import SwiftUI
import SwiftData

struct AiAgentView: View {
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(UserProfileStore.self) private var userProfileStore
    @Query(sort: \WhyItemRecord.createdAt, order: .reverse) private var whyItems: [WhyItemRecord]
    
    @StateObject private var viewModel = AiAgentViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .background(Color(hex: "F9F9F9"))
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            messageBubble(for: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }
                .background(Color(hex: "F9F9F9"))
                .onChange(of: viewModel.messages) { _ in
                    if let lastId = viewModel.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            .onTapGesture {
                isInputFocused = false
            }
            
            chatInputBar
            
            if viewModel.isStreaming {
                HStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                    Text("ExDetox is thinking...")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)
            }
        }
        .background(Color(hex: "F9F9F9").ignoresSafeArea())
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { newValue in
                    if !newValue {
                        viewModel.errorMessage = nil
                    }
                }
            ),
            actions: {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            },
            message: {
                if let message = viewModel.errorMessage {
                    Text(message)
                }
            }
        )
    }
    
    var headerView: some View {
        HStack {
            Text("Healing Companion ❤️‍🩹")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Spacer()
            
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
    }
    
    func messageBubble(for message: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer()
            } else {
                // AI Avatar
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.indigo)
                    .frame(width: 32, height: 32)
                    .background(Color.indigo.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Text(message.text)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(message.isUser ? Color.black : Color.white)
                .foregroundStyle(message.isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
    
    var chatInputBar: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $viewModel.inputText)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .clipShape(Capsule())
                .focused($isInputFocused)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.3) : Color.black)
                    .clipShape(Circle())
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isStreaming)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8) // Safe area handled by structure, but extra padding looks nice
        .background(Color(hex: "F9F9F9"))
    }
    
    func sendMessage() {
        viewModel.sendMessage(
            trackingStore: trackingStore,
            userProfileStore: userProfileStore,
            whyItems: whyItems
        )
    }
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    var text: String
    let isUser: Bool
    let timestamp = Date()
}

#Preview {
    AiAgentView()
}
