//
//  AppConfig.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 27.02.25.
//

import Foundation

enum AppConfig: String {
    case baseHost = "BASE_HOST"
    
    func value<T: LosslessStringConvertible>() -> T? {
        guard
            let object = Bundle.main.object(forInfoDictionaryKey: self.rawValue)
        else {
            return nil
        }
        
        switch object {
        case let value as T:
            return value
        case let string as String:
            return T(string)
        default:
            return nil
        }
    }
}
