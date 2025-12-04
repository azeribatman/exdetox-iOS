//
//  View+SwipeGesture.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 21.09.25.
//

import Foundation
import SwiftUI

struct DisableSwipeGesture: ViewModifier {
    let id: String
    let disabled: Bool

    func body(content: Content) -> some View {
        content
            .onAppear { SwipeGestureManager.shared.setDisabled(disabled, for: id) }
            .onDisappear { SwipeGestureManager.shared.setDisabled(false, for: id) }
    }
}

struct ActiveNavigationContext: ViewModifier {
    let id: String?

    func body(content: Content) -> some View {
        content
            .onAppear { SwipeGestureManager.shared.setActiveNavigation(id) }
            .onDisappear { SwipeGestureManager.shared.setActiveNavigation(nil) }
    }
}

extension View {
    func disableSwipeGesture(id: String = UUID().uuidString, _ disabled: Bool = true) -> some View {
        modifier(DisableSwipeGesture(id: id, disabled: disabled))
    }

    func setActiveNavigationContext(_ id: String?) -> some View {
        modifier(ActiveNavigationContext(id: id))
    }
}
