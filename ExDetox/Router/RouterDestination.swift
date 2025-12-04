//
//  RouterDestination.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 23.05.25.
//

import Foundation
import Photos
import SwiftUI

enum RouterDestination: Identifiable, Hashable {
    var id: String {
        switch self {
        case .onboarding:
            return "onboarding"
        }
    }
    
    case onboarding
    
    @MainActor @ViewBuilder
    static func view(for destination: RouterDestination) -> some View {
        switch destination {
        case .onboarding:
            EmptyView()
        }
    }
}
