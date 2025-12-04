//
//  NetworkError.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 27.02.25.
//

import Foundation

enum NetworkError: Error {
    case urlParsing
    case badResponse
    case unauthorized
    case clientError
    case serverError
    case dateDecoding
    case payment
    case unknown

    var localizedDescription: String {
        switch self {
        case .urlParsing:
            return "Failed to parse the URL."
        case .badResponse:
            return "Received an invalid response from the server."
        case .unauthorized:
            return "Unauthorized access. Please check your credentials."
        case .clientError:
            return "A client-side error occurred. Please try again."
        case .serverError:
            return "A server-side error occurred. Please try again later."
        case .dateDecoding:
            return "Failed to decode a date from the response. Please contact support."
        case .payment:
            return "This content is behind a paywall. Please subscribe to continue."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

