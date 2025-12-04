//
//  Router+Sheet.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 12.08.25.
//

import Foundation
import SwiftUI

struct AppSheetRouter: ViewModifier {
    @Binding var sheet: RouterDestination?
    @Binding var fullScreenSheet: RouterDestination?
    
    func body(content: Content) -> some View {
        content
            .sheet(item: $sheet) { destination in
                RouterDestination.view(for: destination)
            }
            .fullScreenCover(item: $fullScreenSheet) { destination in
                RouterDestination.view(for: destination)
            }
    }
}

extension View {
    func withAppSheet(
        sheet: Binding<RouterDestination?> = .constant(nil),
        fullScreenSheet: Binding<RouterDestination?> = .constant(nil)
    ) -> some View {
        modifier(AppSheetRouter(sheet: sheet, fullScreenSheet: fullScreenSheet))
    }
}
