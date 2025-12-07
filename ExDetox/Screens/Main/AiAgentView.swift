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
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .background(Color.white.opacity(0.95))
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
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
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
                .background(Color.white)
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
            .onTapGesture {
                isInputFocused = false
            }
            
            chatInputBar
        }
        .background(Color.white.ignoresSafeArea())
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
    
    var headerView: some View {
        HStack(spacing: 12) {
            Spacer()
            
            VStack(spacing: 8) {
                // Profile Avatar
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .foregroundStyle(.gray.opacity(0.8))
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 1))
                    .shadow(radius: 1)
                
                VStack(spacing: 2) {
                    Text("Your Friend")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
            }
            
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.white.opacity(0.95))
        .overlay(alignment: .bottom) {
             Divider()
                 .opacity(0.3)
        }
    }
    
    func messageBubble(for message: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 4) {
            if message.isUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(message.text)
                        .font(.body)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(ChatBubbleShape(isUser: true))
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
                    
                    if message == viewModel.messages.last {
                        Text("Read \(message.timestamp.formatted(.dateTime.hour().minute()))")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                            .padding(.trailing, 4)
                    }
                }
            } else {
                // Friend Avatar (small)
                Image(systemName: "person.circle.fill") // Or custom avatar
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(.gray)
                    .background(Color.white)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(message.text)
                        .font(.body)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.systemGray5))
                        .foregroundStyle(.black)
                        .clipShape(ChatBubbleShape(isUser: false))
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                }
                
                Spacer()
            }
        }
    }
    
    var typingIndicator: some View {
        HStack(alignment: .bottom, spacing: 4) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundStyle(.gray)
                .background(Color.white)
                .clipShape(Circle())
            
            TypingIndicatorView()
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color(UIColor.systemGray5))
                .clipShape(ChatBubbleShape(isUser: false))
            
            Spacer()
        }
    }
    
    var chatInputBar: some View {
        HStack(spacing: 8) {
            // Optional "+" button like iMessage
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 20))
                    .foregroundStyle(.gray)
            }
            .padding(.leading, 4)
            
            HStack {
                TextField("iMessage", text: $viewModel.inputText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                
                if !viewModel.inputText.isEmpty {
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.blue)
                    }
                    .transition(.scale)
                    .disabled(viewModel.isStreaming)
                } else {
                     // Mic icon if empty, typical iMessage
                     Image(systemName: "mic.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.gray)
                        .padding(.trailing, 4)
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color.white) // Or slightly translucent effect
        .overlay(alignment: .top) {
            Divider()
                .opacity(0.3)
        }
    }
    
    func sendMessage() {
        viewModel.sendMessage(
            trackingStore: trackingStore,
            userProfileStore: userProfileStore,
            whyItems: whyItems
        )
    }
}

struct ChatBubbleShape: Shape {
    let isUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        let path = UIBezierPath()
        
        if isUser {
            path.move(to: CGPoint(x: 20, y: height))
            path.addLine(to: CGPoint(x: width - 20, y: height))
            path.addCurve(to: CGPoint(x: width, y: height + 0), controlPoint1: CGPoint(x: width - 8, y: height), controlPoint2: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: width, y: 20))
            path.addArc(withCenter: CGPoint(x: width - 20, y: 20), radius: 20, startAngle: 0, endAngle: CGFloat.pi * 1.5, clockwise: false)
            path.addLine(to: CGPoint(x: 20, y: 0))
            path.addArc(withCenter: CGPoint(x: 20, y: 20), radius: 20, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi, clockwise: false)
            path.addLine(to: CGPoint(x: 0, y: height - 20))
            path.addArc(withCenter: CGPoint(x: 20, y: height - 20), radius: 20, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 0.5, clockwise: false)
        } else {
            path.move(to: CGPoint(x: width - 20, y: height))
            path.addLine(to: CGPoint(x: 20, y: height))
            path.addCurve(to: CGPoint(x: 0, y: height + 0), controlPoint1: CGPoint(x: 8, y: height), controlPoint2: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: 0, y: 20))
            path.addArc(withCenter: CGPoint(x: 20, y: 20), radius: 20, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 1.5, clockwise: true)
            path.addLine(to: CGPoint(x: width - 20, y: 0))
            path.addArc(withCenter: CGPoint(x: width - 20, y: 20), radius: 20, startAngle: CGFloat.pi * 1.5, endAngle: 0, clockwise: true)
            path.addLine(to: CGPoint(x: width, y: height - 20))
            path.addArc(withCenter: CGPoint(x: width - 20, y: height - 20), radius: 20, startAngle: 0, endAngle: CGFloat.pi * 0.5, clockwise: true)
        }
        
        return Path(path.cgPath)
    }
}

struct TypingIndicatorView: View {
    @State private var numberOfDots = 3
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 6, height: 6)
                    .scaleEffect(isAnimating ? 1.0 : 0.6)
                    .opacity(isAnimating ? 1.0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
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
