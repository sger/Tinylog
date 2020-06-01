//
//  Router.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 31/08/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import UIKit

public protocol Router: class {
    func present(_ viewController: UIViewController, animated: Bool)
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func push(_ viewController: UIViewController, animated: Bool)
    func push(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismiss(animated: Bool, completion: (() -> Void)?)
    func pop(animated: Bool)
}

extension Router {
    public func present(_ viewController: UIViewController,
                        animated: Bool) {
        present(viewController, animated: animated, completion: nil)
    }

    public func push(_ viewController: UIViewController,
                     animated: Bool) {
        push(viewController, animated: animated, completion: nil)
    }
}
