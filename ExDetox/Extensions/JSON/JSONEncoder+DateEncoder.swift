//
//  JSONEncoder+DateEncoder.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 09.04.25.
//

import Foundation

extension JSONEncoder {
    static var dateEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [
                .withInternetDateTime,
                .withFractionalSeconds
            ]
            let dateString = formatter.string(from: date)
            try container.encode(dateString)
        }
        return encoder
    }
}
