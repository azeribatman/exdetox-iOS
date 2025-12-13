import Foundation
import KeychainSwift

final class ChatMessageLimitManager {
    static let shared = ChatMessageLimitManager()
    
    private let keychain = KeychainSwift()
    private let maxMessagesPerMonth = 1000
    private let maxCharactersPerMessage = 100
    
    private init() {}
    
    var remainingMessages: Int {
        checkAndResetIfNewMonth()
        return max(0, maxMessagesPerMonth - currentMessageCount)
    }
    
    var canSendMessage: Bool {
        return remainingMessages > 0
    }
    
    var currentMessageCount: Int {
        checkAndResetIfNewMonth()
        guard let countString = keychain.get(KeychainKey.chatMessageCount.rawValue),
              let count = Int(countString) else {
            return 0
        }
        return count
    }
    
    var maxCharacters: Int {
        return maxCharactersPerMessage
    }
    
    var maxMessages: Int {
        return maxMessagesPerMonth
    }
    
    func incrementMessageCount() {
        checkAndResetIfNewMonth()
        let newCount = currentMessageCount + 1
        keychain.set(String(newCount), forKey: KeychainKey.chatMessageCount.rawValue)
    }
    
    func truncateMessage(_ message: String) -> String {
        if message.count > maxCharactersPerMessage {
            return String(message.prefix(maxCharactersPerMessage))
        }
        return message
    }
    
    private func checkAndResetIfNewMonth() {
        let currentMonthYear = getCurrentMonthYear()
        let storedMonthYear = keychain.get(KeychainKey.chatMessageResetDate.rawValue)
        
        if storedMonthYear != currentMonthYear {
            keychain.set("0", forKey: KeychainKey.chatMessageCount.rawValue)
            keychain.set(currentMonthYear, forKey: KeychainKey.chatMessageResetDate.rawValue)
        }
    }
    
    private func getCurrentMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }
}
