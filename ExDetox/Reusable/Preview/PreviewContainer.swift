//
//  PreviewContainer.swift
//  ExDetox
//

import SwiftUI

struct PreviewContainer<Content: View>: View {
    @State private var router = Router()
    @State private var container = DependencyContainer(environment: .mock)

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        NavigationStack(path: $router.paths) {
            content()
                .withAppRouter()
        }
        .environment(router)
        .environment(container)
    }
}
