//
//  String+First+Capitalize+Uppercased.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 04.03.25.
//

import Foundation

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}
