//
//  SSEClientType.swift
//  
//
//  Created by Aykhan Safarli on 20.03.25.
//

import Foundation
import Combine

protocol SSEClientType {
    func start(
        _ request: Request,
        eventHandler: @escaping (([SSEClient.Event]) -> Void),
        receivedDataHandler: @escaping (([Data]) -> Void),
        finishedHandler: @escaping ((Error?) -> Void)
    )
    
    func finish()
}
