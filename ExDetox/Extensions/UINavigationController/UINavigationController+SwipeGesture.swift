//
//  UINavigationController+SwipeGesture.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 21.09.25.
//

import Foundation
import UIKit

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    open override func viewDidLoad() {
        super.viewDidLoad()

        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1 && !SwipeGestureManager.shared.isDisabled
    }
}
