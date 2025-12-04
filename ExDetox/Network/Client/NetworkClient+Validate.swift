//
//  NetworkClient+Validate.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 13.03.25.
//

import Foundation

extension NetworkClient {
    func validate(response: URLResponse) async throws {
        guard
            let httpResponse = response as? HTTPURLResponse
        else {
            throw NetworkError.badResponse
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            return
        case 401:
            throw NetworkError.unauthorized
        case 402:
            throw NetworkError.payment
        case 400..<500:
            throw NetworkError.clientError
        case 500...:
            throw NetworkError.serverError
        default:
            throw NetworkError.unknown
        }
    }
    
    func validate<T: Decodable>(
        response: URLResponse,
        request: Request,
        data: Data,
        client: NetworkClientType
    ) async throws -> T {
        guard
            let httpResponse = response as? HTTPURLResponse
        else {
            throw NetworkError.badResponse
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            return try decode(and: data)
        case 401:
            throw NetworkError.unauthorized
        case 402:
            throw NetworkError.payment
        case 400..<500:
            let error = try? JSONDecoder().decode(NetworkErrorModel.self, from: data)
            throw error ?? NetworkError.clientError
        case 500...:
            throw NetworkError.serverError
        default:
            throw NetworkError.unknown
        }
    }
}
