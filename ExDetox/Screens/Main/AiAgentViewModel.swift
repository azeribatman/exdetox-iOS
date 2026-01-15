import Foundation
import SwiftData

@MainActor
final class AiAgentViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isStreaming = false
    @Published var errorMessage: String?
    @Published var hasReachedMonthlyLimit = false
    
    private let sseClient: SSEClientType
    private var streamingMessageID: UUID?
    private var hasFinishedCurrentStream = false
    private let messageLimitManager = ChatMessageLimitManager.shared
    
    var remainingMessages: Int {
        messageLimitManager.remainingMessages
    }
    
    var maxCharacters: Int {
        messageLimitManager.maxCharacters
    }
    
    init(sseClient: SSEClientType = SSEClient()) {
        self.sseClient = sseClient
        self.hasReachedMonthlyLimit = !messageLimitManager.canSendMessage
    }
    
    func sendMessage(
        trackingStore: TrackingStore,
        userProfileStore: UserProfileStore,
        whyItems: [WhyItemRecord]
    ) {
        guard messageLimitManager.canSendMessage else {
            hasReachedMonthlyLimit = true
            AnalyticsManager.shared.trackAiLimitReached()
            return
        }
        
        let trimmed = messageLimitManager.truncateMessage(
            inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        guard !trimmed.isEmpty else { return }
        
        messageLimitManager.incrementMessageCount()
        hasReachedMonthlyLimit = !messageLimitManager.canSendMessage
        
        inputText = ""
        errorMessage = nil
        sseClient.finish()
        
        let userMessage = ChatMessage(text: trimmed, isUser: true)
        messages.append(userMessage)
        
        // Track AI message sent
        AnalyticsManager.shared.trackAiMessageSent(messageLength: trimmed.count)
        
        let history = historyString(excludingLatestUser: true)
        let request = AIChatRequest(body: buildBody(
            userMessage: trimmed,
            history: history,
            trackingStore: trackingStore,
            userProfileStore: userProfileStore,
            whyItems: whyItems
        ))
        
        isStreaming = true
        streamingMessageID = nil
        hasFinishedCurrentStream = false
        
        sseClient.start(
            request,
            eventHandler: { [weak self] events in
                self?.handle(events: events)
            },
            receivedDataHandler: { [weak self] datas in
                self?.handle(datas: datas)
            },
            finishedHandler: { [weak self] error in
                self?.handleCompletion(error: error)
            }
        )
    }
    
    private func buildBody(
        userMessage: String,
        history: String,
        trackingStore: TrackingStore,
        userProfileStore: UserProfileStore,
        whyItems: [WhyItemRecord]
    ) -> AIChatRequest.Body {
        let profile = userProfileStore.profile
        let name = profile.name.isEmpty ? "Friend" : profile.name
        let exName = profile.exName.isEmpty ? "ex" : profile.exName
        let streak = "\(trackingStore.currentStreakDays)"
        let phase = trackingStore.currentLevel.title
        let whyList = whyItems.isEmpty ? "Not provided" : whyItems.map { $0.title }.joined(separator: "; ")
        
        let variables = AIChatRequest.Variables(
            name: name,
            exname: exName,
            streakdays: streak,
            userphase: phase,
            whylist: whyList,
            history: history,
            user_message: userMessage
        )
        
        let prompt = AIChatRequest.Prompt(
            id: "pmpt_693551ff74208190b30c6831c010104e0651b8c5d150e4ef",
            version: "4",
            variables: variables
        )
        
        return AIChatRequest.Body(
            prompt: prompt,
            stream: true,
            reasoning: [:],
            input: [],
            store: true,
            include: [
                "reasoning.encrypted_content",
                "web_search_call.action.sources"
            ]
        )
    }
    
    private func historyString(excludingLatestUser: Bool) -> String {
        var historyMessages = messages
        if excludingLatestUser {
            historyMessages = Array(historyMessages.dropLast())
        }
        return historyMessages.map { message in
            let role = message.isUser ? "User" : "Assistant"
            let trimmed = String(message.text.suffix(30))
            return "\(role): \(trimmed)"
        }
        .joined(separator: "\n")
    }
    
    private func handle(events: [SSEClient.Event]) {
        events.forEach { event in
            guard let data = event.value.data(using: .utf8) else { return }
            parseAndHandle(data)
        }
    }
    
    private func handle(datas: [Data]) {
        datas.forEach(parseAndHandle)
    }
    
    private func parseAndHandle(_ data: Data) {
        guard let envelope = try? JSONDecoder().decode(OpenAIStreamEnvelope.self, from: data) else { return }
        handle(envelope: envelope)
    }
    
    private func handle(envelope: OpenAIStreamEnvelope) {
        if let message = envelope.error?.message {
            errorMessage = message
            isStreaming = false
            return
        }
        
        switch envelope.type {
        case "response.output_text.delta":
            if let delta = envelope.delta {
                appendDelta(delta)
            }
        case "response.output_text.done":
            finishStreaming(text: envelope.text)
        case "response.completed":
            finishStreaming(text: envelope.text)
        default:
            break
        }
    }
    
    private func appendDelta(_ delta: String) {
        if streamingMessageID == nil {
            let assistant = ChatMessage(text: "", isUser: false)
            streamingMessageID = assistant.id
            messages.append(assistant)
        }
        
        guard let id = streamingMessageID, let index = messages.firstIndex(where: { $0.id == id }) else { return }
        messages[index].text.append(delta)
    }
    
    private func finishStreaming(text: String?) {
        if hasFinishedCurrentStream {
            return
        }
        
        guard let id = streamingMessageID, let index = messages.firstIndex(where: { $0.id == id }) else {
            if let text, !text.isEmpty {
                messages.append(ChatMessage(text: text, isUser: false))
            }
            isStreaming = false
            streamingMessageID = nil
            hasFinishedCurrentStream = true
            return
        }
        
        if let text, !text.isEmpty {
            messages[index].text = text
        }
        
        isStreaming = false
        streamingMessageID = nil
        hasFinishedCurrentStream = true
    }
    
    private func handleCompletion(error: Error?) {
        if let error {
            errorMessage = error.localizedDescription
        }
        isStreaming = false
        hasFinishedCurrentStream = true
        streamingMessageID = nil
    }
}

private struct OpenAIStreamEnvelope: Decodable {
    struct StreamError: Decodable {
        let message: String?
    }
    
    let type: String?
    let delta: String?
    let text: String?
    let error: StreamError?
}
