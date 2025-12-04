//
//  MockResponses.swift
//  ExDetox
//
//  Created by Ayxan Səfərli on 21.09.25.
//

import Foundation

enum MockResponses {
    struct Example: Decodable {
        let id: String
        let name: String
        let description: String?
    }

    struct User: Decodable {
        let userId: String
        let username: String
        let email: String
    }
}
