//
//  UIDevice+Identifier.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 13.03.25.
//

import Foundation
import UIKit

extension UIDevice {
    static let identifier = UIDevice
        .current
        .identifierForVendor?
        .uuidString ?? UUID().uuidString
}
