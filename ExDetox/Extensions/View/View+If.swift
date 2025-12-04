//
//  View+If.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 03.03.25.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(
        _ condition: Bool,
        content: (Self) -> Content
    ) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func ifLet<T, Content: View>(
        _ optional: T?,
        content: (T, Self) -> Content
    ) -> some View {
        if let optional {
            content(optional, self)
        } else {
            self
        }
    }
}
