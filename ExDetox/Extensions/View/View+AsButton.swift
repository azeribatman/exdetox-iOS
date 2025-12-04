//
//  View+AsButton.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 21.05.25.
//

import Foundation
import SwiftUI

extension View {
    func button(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            self.contentShape(Rectangle())
        }
    }
    
    func button(action: @Sendable @escaping () async -> Void) -> some View {
        Button {
            Task { await action() }
        } label: {
            self.contentShape(Rectangle())
        }
    }
}
