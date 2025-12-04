//
//  CenteredScrollView.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 21.04.25.
//

import Foundation
import SwiftUI

struct CenteredScrollView<Content: View> {
    @ViewBuilder let content: Content
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                content
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
            }
        }
    }
}

