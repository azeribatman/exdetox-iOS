//
//  UIApplication+EndEditing.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 05.03.25.
//

import Foundation
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
