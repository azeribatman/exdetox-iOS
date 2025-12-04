//
//  NetworkErrorModel.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 17.04.25.
//

import Foundation

struct NetworkErrorModel: Error, Codable {
    let message: String
}

extension Error {
    var asNetworkErrorModel: NetworkErrorModel? {
        return self as? NetworkErrorModel
    }
}
