//
//  ExDetoxApp.swift
//  ExDetox
//
//  Created by Ayxan Səfərli on 21.09.25.
//

import SwiftUI

@main
struct ExDetoxApp: App {
    @State private var router = Router.base
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.paths, root: root)
                .sheet(item: $router.sheet, content: sheet)
                .fullScreenCover(item: $router.fullScreenSheet, content: sheet)
                .environment(router)
                .preferredColorScheme(.light)
        }
    }
    
    private func root() -> some View {
        LaunchView().withAppRouter()
    }
    
    private func sheet(for destination: RouterDestination) -> some View {
        RouterDestination.view(for: destination)
    }
}
