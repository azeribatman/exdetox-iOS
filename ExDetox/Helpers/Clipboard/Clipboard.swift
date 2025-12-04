//
//  Clipboard.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 04.03.25.
//

import Foundation
import UIKit

enum Clipboard {
    static func get() -> String {
        return UIPasteboard.general.string ?? ""
    }
    
    static func copy(text: String) {
        UIPasteboard.general.string = text
        Haptics.notification(type: .success)
    }
}
