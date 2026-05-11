//
//  AppEnvironment.swift
//  ExDetox
//

import Foundation

enum AppEnvironment {
    case live
    case mock

    static var current: AppEnvironment {
        #if MOCK
        return .mock
        #else
        return .live
        #endif
    }
}
