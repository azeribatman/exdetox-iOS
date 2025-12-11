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
        case .onboarding1:
            return "onboarding1"
        case .onboarding2:
            return "onboarding2"
        case .onboarding3:
            return "onboarding3"
        case .onboardingNotification:
            return "onboardingNotification"
        case .onboarding4:
            return "onboarding4"
        case .onboarding5:
            return "onboarding5"
        case .main:
            return "main"
        }
    }
    
    case onboarding1
    case onboarding2
    case onboarding3
    case onboardingNotification
    case onboarding4
    case onboarding5
    case main
    
    @MainActor @ViewBuilder
    static func view(for destination: RouterDestination) -> some View {
        switch destination {
        case .onboarding1:
            OnboardingView1()
        case .onboarding2:
            OnboardingView2()
        case .onboarding3:
            OnboardingView3()
        case .onboardingNotification:
            OnboardingNotificationView()
        case .onboarding4:
            OnboardingView4()
        case .onboarding5:
            OnboardingView5()
        case .main:
            MainView()
        }
    }
}
