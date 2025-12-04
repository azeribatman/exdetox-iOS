//
//  Router+Extension.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 31.05.25.
//

import Foundation
import SwiftUI

struct AppRouter: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .navigationDestination(for: RouterDestination.self) { destination in
                RouterDestination.view(for: destination)
            }
    }
}

extension View {
    func withAppRouter() -> some View {
        modifier(AppRouter())
    }
}
