//
//  Date+AsString.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 09.04.25.
//

import Foundation

extension Date {
    func asString(with format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
