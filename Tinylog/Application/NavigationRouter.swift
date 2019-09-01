//
//  NavigationRouter.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 31/08/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import UIKit

public class NavigationRouter: NSObject {
    
    private let navigationController: UINavigationController
    private let rootViewController: UIViewController?
    private var completions: [UIViewController: (() -> Void)] = [:]
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.rootViewController = navigationController.viewControllers.first
        super.init()
        navigationController.delegate = self
    }
}

// MARK: - Router
extension NavigationRouter: Router {
    public func pop(animated: Bool) {
        guard let rootViewController = rootViewController else {
            navigationController.popToRootViewController(animated: animated)
            return
        }
        performCompletion(for: rootViewController)
        navigationController.popToViewController(rootViewController, animated: animated)
    }
    
    public func push(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        completions[viewController] = completion
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    public func present(_ viewController: UIViewController,
                        animated: Bool,
                        completion: (() -> Void)?) {
        completions[viewController] = completion
        navigationController.present(viewController, animated: animated, completion: nil)
    }
    
    public func dismiss(animated: Bool) {
        navigationController.dismiss(animated: true, completion: nil)
    }
    
    private func performCompletion(for viewController: UIViewController) {
        guard let completion = completions[viewController] else {
            return
        }
        completion()
        completions[viewController] = nil
    }
}

// MARK: - UINavigationControllerDelegate

extension NavigationRouter: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController,
                                     didShow viewController: UIViewController,
                                     animated: Bool) {
        
        guard let dismissedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
            !navigationController.viewControllers.contains(dismissedViewController) else { return }
        print("dismissedViewController \(dismissedViewController)")
        print("viewController \(viewController)")
        performCompletion(for: dismissedViewController)
    }
}

