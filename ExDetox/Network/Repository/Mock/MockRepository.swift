//
//  MockRepository.swift
//  ExDetox
//
//  Created by Ayxan Səfərli on 21.09.25.
//

import Foundation

final class MockRepository: MockRepositoryType {
    func fetchExampleData(id: String) async throws -> MockResponses.Example {
        try await Task.sleep(nanoseconds: 500_000_000)

        return MockResponses.Example(
            id: id,
            name: "Example Item \(id)",
            description: "This is a mock example response for id: \(id)"
        )
    }

    func fetchUserData(userId: String) async throws -> MockResponses.User {
        try await Task.sleep(nanoseconds: 300_000_000)

        return MockResponses.User(
            userId: userId,
            username: "user_\(userId)",
            email: "user\(userId)@example.com"
        )
    }
}
