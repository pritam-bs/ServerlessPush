//
//  UIWindow+Extensions.swift
//  ServerlessPush
//
//  Created by Pritam on 3/3/21.
//

import UIKit

extension UIWindow {
    /// Requests top view controller object.
    /// - Parameters:
    ///    - viewController: an based view controller.
    /// - Returns: A top view controller based on a param if found. Otherwise `nil`.
    func topViewController(base viewController: UIViewController?) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(base: presented)
        }
        return viewController
    }
    
    /// Requests visible view controller.
    /// - Returns: A visible view conroller object if found. Otherwise `nil`.
    var visibleViewController: UIViewController? {
        return topViewController(base: rootViewController)
    }
    
    /// Swaps root view controller.
    /// - Parameters:
    ///    - newController: A view controller which change with
    ///    - animated: Whether animated.
    ///    - completion: Called whenever swap action has been finished.
    func swapRootViewContoller(
        with newController: UIViewController,
        animated: Bool,
        completion: (() -> Void)? = nil) {
        if !animated {
            rootViewController = newController
            completion?()
        } else {
            UIView.transition(
                with: self,
                duration: 0.25,
                options: .transitionCrossDissolve,
                animations: { [weak self] in
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                self?.rootViewController = newController
                UIView.setAnimationsEnabled(oldState)
                }, completion: { completed in
                    if completed {
                        completion?()
                    }
                }
            )
        }
    }
}
