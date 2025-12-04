//
//  KeychainWrapper.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 27.02.25.
//

import Foundation
import KeychainSwift

@propertyWrapper struct Keychain {
    let keychain = KeychainSwift()
    let key: KeychainKey
    
    var wrappedValue: String? {
        get { keychain.get(key.rawValue) }
        set {
            guard let newValue else { return }
            keychain.set(newValue, forKey: key.rawValue)
        }
    }
}
