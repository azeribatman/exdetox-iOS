//
//  SSEClient.swift
//
//
//  Created by Aykhan Safarli on 20.03.25.
//

import Foundation

class SSEClientDelegate: NSObject, URLSessionDataDelegate {
    private let eventHandler: ([SSEClient.Event]) -> Void
    private let receivedDataHandler: ([Data]) -> Void
    private let finishedHandler: (Error?) -> Void
    private let onCompletion: () -> Void
    
    private let lastRequest: URLRequest?
    private var lastData: Data?
    
    init(
        lastRequest: URLRequest,
        eventHandler: @escaping ([SSEClient.Event]) -> Void,
        receivedDataHandler: @escaping ([Data]) -> Void,
        finishedHandler: @escaping (Error?) -> Void,
        onCompletion: @escaping () -> Void
    ) {
        self.lastRequest = lastRequest
        self.eventHandler = eventHandler
        self.receivedDataHandler = receivedDataHandler
        self.finishedHandler = finishedHandler
        self.onCompletion = onCompletion
    }
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        self.lastData = data
        
        let dataArray = String(decoding: data, as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "\n")
            .map { String($0) }
        
        // Debug: Print the raw data to understand the format
        print("🔍 SSE Raw Data Array:")
        for (index, line) in dataArray.enumerated() {
            print("[\(index)]: '\(line)'")
        }
        
        // Parse events first (these contain metadata like chatId)
        let events = SSEClient.Event.parse(dataArray)
        
        // Check for error responses in the data
        for line in dataArray {
            if line.contains("\"statusCode\":401") || line.contains("\"message\":\"Unauthorized\"") {
                DispatchQueue.main.async { [weak self] in
                    self?.finishedHandler(NetworkError.unauthorized)
                    self?.onCompletion()
                }
                return
            }
            
            // Check for other error status codes
            if line.contains("\"statusCode\":400") || line.contains("\"statusCode\":500") {
                DispatchQueue.main.async { [weak self] in
                    self?.finishedHandler(NetworkError.serverError)
                    self?.onCompletion()
                }
                return
            }
        }
        
        // Parse JSON data separately (these contain the actual content)
        let datas = dataArray
            .filter { $0.contains("data: {") }
            .map { $0.replacingOccurrences(of: "data: ", with: "") }
            .compactMap {
                return $0.data(using: .utf8)
            }
        
        let response = dataTask.response as? HTTPURLResponse
        NetworkLogger.log(
            request: lastRequest,
            data: lastData,
            response: response
        )
        
        DispatchQueue.main.async { [weak self] in
            // Call event handler only if we have events
            if !events.isEmpty {
                self?.eventHandler(events)
            }
            
            // Call data handler only if we have data
            if !datas.isEmpty {
                self?.receivedDataHandler(datas)
            }
        }
    }
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: (any Error)?
    ) {
        let response = task.response as? HTTPURLResponse
        NetworkLogger.log(
            request: lastRequest,
            data: lastData,
            response: response
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.finishedHandler(error)
            self?.onCompletion()
        }
    }
}

final class SSEClient: SSEClientType {
    private var delegate: SSEClientDelegate?
    private var session: URLSession?
    
    private var lastData: Data?
    private var lastRequest: URLRequest?
    
    private var eventHandler: (([Event]) -> Void)?
    private var receivedDataHandler: (([Data]) -> Void)?
    private var finishedHandler: ((Error?) -> Void)?
    
    deinit {
        finish()
    }
    
    func start(
        _ request: Request,
        eventHandler: @escaping (([Event]) -> Void),
        receivedDataHandler: @escaping (([Data]) -> Void),
        finishedHandler: @escaping ((Error?) -> Void)
    ) {
        guard let urlRequest = try? request.urlRequest() else { return }
        
        delegate = SSEClientDelegate(
            lastRequest: urlRequest,
            eventHandler: eventHandler,
            receivedDataHandler: receivedDataHandler,
            finishedHandler: finishedHandler
        ) {}
        
        let session = URLSession(
            configuration: .default,
            delegate: delegate,
            delegateQueue: nil
        )
        self.session = session
        
        self.eventHandler = eventHandler
        self.receivedDataHandler = receivedDataHandler
        self.finishedHandler = finishedHandler
        self.lastRequest = urlRequest
        
        session.dataTask(with: urlRequest).resume()
    }
    
    func finish() {
        session?.invalidateAndCancel()
        session = nil
        eventHandler = nil
        receivedDataHandler = nil
        finishedHandler = nil
        lastRequest = nil
    }
}
