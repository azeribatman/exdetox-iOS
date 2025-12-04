import SwiftUI

struct AiAgentView: View {
    // MARK: - State
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hi there! I'm here to listen. How are you feeling today?", isUser: false)
    ]
    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
                .background(Color(hex: "F9F9F9"))
            
            // Chat History
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(messages) { message in
                            messageBubble(for: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }
                .background(Color(hex: "F9F9F9"))
                .onChange(of: messages) { _ in
                    if let lastId = messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            .onTapGesture {
                isInputFocused = false
            }
            
            // Input Area
            chatInputBar
        }
        .background(Color(hex: "F9F9F9").ignoresSafeArea())
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Subviews
    
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
            TextField("Type a message...", text: $inputText)
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
                    .background(inputText.isEmpty ? Color.gray.opacity(0.3) : Color.black)
                    .clipShape(Circle())
            }
            .disabled(inputText.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8) // Safe area handled by structure, but extra padding looks nice
        .background(Color(hex: "F9F9F9"))
    }
    
    // MARK: - Actions
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMsg = ChatMessage(text: inputText, isUser: true)
        messages.append(userMsg)
        
        let sentText = inputText
        inputText = ""
        
        // Mock Reply
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let replyText = generateMockReply(for: sentText)
            let aiMsg = ChatMessage(text: replyText, isUser: false)
            withAnimation {
                messages.append(aiMsg)
            }
        }
    }
    
    func generateMockReply(for input: String) -> String {
        let responses = [
            "I hear you. It takes time to heal, but you're doing great.",
            "That sounds tough. Remember to be gentle with yourself today.",
            "You are stronger than you know. Keep focusing on your growth.",
            "I'm here for you. Tell me more about how that makes you feel.",
            "Sending you virtual hugs. You've got this! ✨"
        ]
        return responses.randomElement() ?? "I'm listening."
    }
}

// MARK: - Models

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
}

#Preview {
    AiAgentView()
}
