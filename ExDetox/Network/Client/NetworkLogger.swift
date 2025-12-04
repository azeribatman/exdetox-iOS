//
//  NetworkLogger.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 27.02.25.
//

import Foundation

enum NetworkLogger {
    static func log(
        request: URLRequest?,
        url: URL? = nil,
        data: Data?,
        response: URLResponse?
    ) {
        let emptyMessage = "❌ IS EMPTY"
        
        let url = (
            request?.url?.absoluteString ?? url?.absoluteString
        ) ?? emptyMessage
        let method = request?.httpMethod ?? emptyMessage
        let headers = request?.allHTTPHeaderFields ?? [:]
        let body = request?.httpBody
        let status = (response as? HTTPURLResponse)?.statusCode ?? .zero
        
        print("""
        \n🔍 START LOGGING ----------------------------------
        
        🏁 STATUS CODE: \(status)
        
        🌐 URL: \(url)
        
        📩 METHOD: \(method)
        
        📌 HEADERS: \(headers.isEmpty ? emptyMessage : "\(headers as AnyObject)")
        
        """)

        logData(body, title: "📤 Request Body")
        logData(data, title: "📥 Response Data")

        print("🛑 END LOGGING ----------------------------------\n")
    }
    
    private static func logData(_ data: Data?, title: String) {
        guard let data,
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("\(title): ❌ IS EMPTY\n")
            return
        }
        print("\(title): \(jsonString)\n")
    }
}
