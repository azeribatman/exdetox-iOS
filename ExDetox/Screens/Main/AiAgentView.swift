import SwiftUI
import SwiftData
import UIKit

struct AiAgentView: View {
    @Environment(TrackingStore.self) private var trackingStore
    @Environment(UserProfileStore.self) private var userProfileStore
    @Query(sort: \WhyItemRecord.createdAt, order: .reverse) private var whyItems: [WhyItemRecord]
    
    @StateObject private var viewModel = AiAgentViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var showSettings = false
    
    private let creamBg = Color(hex: "F5F0E8")
    private let cardBg = Color(hex: "FFFDF9")
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            if viewModel.messages.isEmpty {
                emptyStateView
            } else {
                chatScrollView
            }
            
            chatInputBar
        }
        .background(creamBg.ignoresSafeArea())
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
        .onAppear {
            viewModel.messages = [.init(text: "Hi \(userProfileStore.profile.name)! I'm here to listen. How are you feeling today?", isUser: false)]
        }
    }
    
    private var chatScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.messages) { message in
                        messageBubble(for: message)
                            .id(message.id)
                    }
                    
                    if viewModel.isStreaming && viewModel.messages.last?.isUser == true {
                        typingIndicator
                            .id("typingIndicator")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
            .onChange(of: viewModel.messages) { _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.isStreaming) { isStreaming in
                if isStreaming {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: isInputFocused) { focused in
                if focused {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        scrollToBottom(proxy: proxy)
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if viewModel.isStreaming && viewModel.messages.last?.isUser == true {
             withAnimation {
                 proxy.scrollTo("typingIndicator", anchor: .bottom)
             }
        } else if let lastId = viewModel.messages.last?.id {
            withAnimation {
                proxy.scrollTo(lastId, anchor: .bottom)
            }
        }
    }
    
    private var headerView: some View {
        HStack(alignment: .center) {
            Text("Your Friend")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.primary)
            
            Spacer()
            
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
            
            Text("🫂")
                .font(.system(size: 64))
                .frame(width: 100, height: 100)
                .background(cardBg)
                .clipShape(Circle())
            
            VStack(spacing: 8) {
                Text("I'm here for you")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                
                Text("Talk to me about anything.\nNo judgment, just support.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 10) {
                quickPromptButton("I'm feeling anxious about my ex")
                quickPromptButton("I need motivation to stay strong")
                quickPromptButton("Help me understand my feelings")
            }
            .padding(.top, 12)
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    private func quickPromptButton(_ text: String) -> some View {
        Button {
            viewModel.inputText = text
            sendMessage()
        } label: {
            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private func messageBubble(for message: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 50)
                
                Text(message.text)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                Text(message.text)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                
                Spacer(minLength: 50)
            }
        }
        .transition(.asymmetric(
            insertion: .scale(scale: 0.94, anchor: message.isUser ? .bottomTrailing : .bottomLeading).combined(with: .opacity),
            removal: .opacity
        ))
    }
    
    private var typingIndicator: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TypingDotsView()
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            
            Spacer(minLength: 50)
        }
    }
    
    private var chatInputBar: some View {
        HStack(spacing: 10) {
            TextField("What's on your mind?", text: $viewModel.inputText)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .focused($isInputFocused)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .submitLabel(.send)
                .onSubmit { sendMessage() }
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(viewModel.inputText.isEmpty || viewModel.isStreaming ? .black.opacity(0.15) : .black)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.inputText.isEmpty)
            }
            .disabled(viewModel.inputText.isEmpty || viewModel.isStreaming)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(creamBg)
    }
    
    private func sendMessage() {
        guard !viewModel.inputText.isEmpty else { return }
        Haptics.feedback(style: .light)
        viewModel.sendMessage(
            trackingStore: trackingStore,
            userProfileStore: userProfileStore,
            whyItems: whyItems
        )
    }
}

struct TypingDotsView: View {
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.primary.opacity(0.4))
                    .frame(width: 7, height: 7)
                    .offset(y: animating ? -4 : 0)
                    .animation(
                        Animation.easeInOut(duration: 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.15),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
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
