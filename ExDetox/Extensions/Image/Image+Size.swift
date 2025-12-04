//
//  Image+Size.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 13.05.25.
//

import Foundation
import SwiftUI

extension Image {
    func build(
        size: CGFloat,
        contentMode: ContentMode = .fit,
        foregroundColor: Color? = nil
    ) -> some View {
        self
            .renderingMode(foregroundColor == nil ? nil : .template)
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .frame(width: size, height: size)
            .foregroundStyle(foregroundColor ?? Color(.label))
    }
}
