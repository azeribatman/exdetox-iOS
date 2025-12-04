//
//  MockRepositoryType.swift
//  ExDetox
//
//  Created by Ayxan Səfərli on 21.09.25.
//

import Foundation

protocol MockRepositoryType {
    func fetchExampleData(id: String) async throws -> MockResponses.Example
    func fetchUserData(userId: String) async throws -> MockResponses.User
}
