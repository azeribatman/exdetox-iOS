//
//  View+HiddenIf.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 31.05.25.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func hiddenIf(_ condition: Bool) -> some View {
        if !condition {
            self
        }
    }
}
