//
//  MockRequests.swift
//  ExDetox
//
//  Created by Ayxan Səfərli on 21.09.25.
//

import Foundation

enum MockRequests: Request {
    case exampleRequest(String)

    var path: String {
        switch self {
        case .exampleRequest:
            return "/api/example"
        }
    }

    var method: RequestMethod {
        switch self {
        case .exampleRequest:
            return .GET
        }
    }

    var queries: [String: String]? {
        switch self {
        case .exampleRequest(let id):
            return ["id": id]
        }
    }
}
