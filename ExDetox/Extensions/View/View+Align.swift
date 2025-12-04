//
//  View+Align.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 31.05.25.
//

import Foundation
import SwiftUI

extension View {
    func leftAlign() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
    }
    
    func centerAlign() -> some View {
        self
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }
}
