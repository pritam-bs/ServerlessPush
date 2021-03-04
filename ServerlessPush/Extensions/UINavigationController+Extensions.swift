//
//  UINavigationController+Extensions.swift
//  ServerlessPush
//
//  Created by Pritam on 3/3/21.
//

import UIKit

extension UINavigationController {
    func replaceViewController(_ viewController: UIViewController, animated: Bool) {
        var controllers = viewControllers
        _ = controllers.popLast()
        controllers.append(viewController)
        setViewControllers(controllers, animated: animated)
    }
}
