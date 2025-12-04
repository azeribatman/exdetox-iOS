//
//  NSMutableData+AppendString.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 14.04.25.
//

import Foundation

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
