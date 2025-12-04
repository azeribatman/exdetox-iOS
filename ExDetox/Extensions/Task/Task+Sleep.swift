//
//  Task+Sleep.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 26.04.25.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let nanoseconds = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: nanoseconds)
    }
}
