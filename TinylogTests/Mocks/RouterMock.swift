//
//  RouterMock.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 31/08/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

@testable import Tinylog

class RouterMock: Router {
    
    var viewControllers: [UIViewController] = []
    private var completions: [UIViewController: (() -> Void)] = [:]
    var presentedViewController: UIViewController?
    
    func present(_ viewController: UIViewController,
                        animated: Bool) {
        present(viewController, animated: animated, completion: nil)
    }
    
    func push(_ viewController: UIViewController,
                     animated: Bool) {
        push(viewController, animated: animated, completion: nil)
    }
    
    func push(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        viewControllers.append(viewController)
    }
    
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if viewController is UINavigationController {
            let nc = viewController as? UINavigationController
            presentedViewController = nc?.viewControllers.first
        } else {
            presentedViewController = viewController
        }
    }
    
    func dismiss(animated: Bool) {
        presentedViewController = nil
    }
    
    public func pop(animated: Bool) {
        guard let first = viewControllers.first else { return }
        performCompletion(for: first)
        viewControllers = [first]
    }
    
    private func performCompletion(for viewController: UIViewController) {
        guard let completion = completions[viewController] else {
            return
        }
        completion()
        completions[viewController] = nil
    }
}
