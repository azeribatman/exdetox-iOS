//
//  LaunchView.swift
//  ExDetox
//
//  Created by Ayxan Səfərli on 21.09.25.
//

import Foundation
import SwiftUI

struct LaunchView: View {
    @Environment(Router.self) private var router
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        Text("LaunchView")
            .onAppear {
                Task {
                    try? await Task.sleep(seconds: 1)
                    if hasCompletedOnboarding {
                        router.set(.main)
                    } else {
                        router.set(.onboarding1)
                    }
                }
            }
    }
}
