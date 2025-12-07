import Foundation

struct AIChatRequest: Request {
    struct Body: Encodable {
        let prompt: Prompt
        let stream: Bool
        let reasoning: [String: String]
        let input: [String]
        let store: Bool
        let include: [String]
    }
    
    struct Prompt: Encodable {
        let id: String
        let version: String
        let variables: Variables
    }
    
    struct Variables: Encodable {
        let name: String
        let exname: String
        let streakdays: String
        let userphase: String
        let whylist: String
        let history: String
        let user_message: String
    }
    
    let body: Body
    
    var path: String { "/v1/responses" }
    
    var fullPath: String? {
        if let base: String = AppConfig.baseHost.value(), !base.isEmpty {
            let normalizedBase = base.hasSuffix("/") ? String(base.dropLast()) : base
            let resolvedBase = normalizedBase.hasPrefix("http") ? normalizedBase : "https://\(normalizedBase)"
            return "\(resolvedBase)\(path)"
        }
        return "https://api.openai.com\(path)"
    }
    
    var method: RequestMethod { .POST }
    var httpBody: Encodable? { body }
    var needAuth: Bool { false }
    
    var headers: [String: String] {
        var headers = [
            "Accept": "text/event-stream",
            "Content-Type": "application/json"
        ]
        
        if let key: String = AppConfig.openapikey.value(), !key.isEmpty {
            headers["Authorization"] = "Bearer \(key)"
        }
        
        return headers
    }
}
