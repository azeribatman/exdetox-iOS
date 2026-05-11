//
//  NetworkClientFactory.swift
//  ExDetox
//
//  ExDetox currently has only a live NetworkClient (mocking happens at the
//  repository layer in Network/Repository/Mock/). The factory still switches
//  on AppEnvironment so the indirection is in place for the day a mock
//  client is added.

import Foundation

enum NetworkClientFactory {
    static func make(for environment: AppEnvironment = .current) -> NetworkClientType {
        switch environment {
        case .live, .mock:
            return NetworkClient(session: .shared)
        }
    }
}
