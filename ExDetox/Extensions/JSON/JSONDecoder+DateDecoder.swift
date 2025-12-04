//
//  JSONDecoder+DateDecoder.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 09.04.25.
//

import Foundation

extension JSONDecoder {
    static var dateDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [
                .withInternetDateTime,
                .withFractionalSeconds
            ]
            
            guard let date = formatter.date(from: dateString) else {
                throw NetworkError.dateDecoding
            }
            
            return date
        }
        return decoder
    }
}
