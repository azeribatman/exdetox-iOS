//
//  Haptics.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 04.03.25.
//

import Foundation
import UIKit

enum Haptics {
    static func notification(
        type: UINotificationFeedbackGenerator.FeedbackType
    ) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func feedback(
        style: UIImpactFeedbackGenerator.FeedbackStyle
    ) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
