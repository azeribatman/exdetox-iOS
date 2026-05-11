//
//  DependencyContainer.swift
//  ExDetox
//
//  Lightweight DI container. ExDetox's stores (TrackingStore, UserProfileStore,
//  NotificationStore) are still created in ExDetoxApp and injected via
//  .environment(), so this container is intentionally minimal for now. It exists
//  so previews and future feature repositories have a place to plug in.

import Foundation
import SwiftUI

@MainActor
@Observable
final class DependencyContainer {
    let environment: AppEnvironment
    let networkClient: NetworkClientType

    init(environment: AppEnvironment = .current) {
        self.environment = environment
        self.networkClient = NetworkClientFactory.make(for: environment)
    }
}
