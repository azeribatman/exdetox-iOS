//
//  String+Replace.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 28.04.25.
//

import Foundation

extension String {
    var replaceSpaces: String {
        self.replacingOccurrences(of: " ", with: "")
    }
}
