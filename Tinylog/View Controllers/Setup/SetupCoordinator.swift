//
//  SetupCoordinator.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 27/08/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import Foundation

protocol SetupCoordinatorDelegate: AnyObject {
    func setupCoordinatorDidFinish(_ coordinator: Coordinator)
}

final class SetupCoordinator: BaseCoordinator {
    
    private let window: UIWindow
    let navigationController: UINavigationController
    
    weak var delegate: SetupCoordinatorDelegate?
    
    init(window: UIWindow, navigationController: UINavigationController) {
        self.window = window
        self.navigationController = navigationController
        self.navigationController.isNavigationBarHidden = true
    }
    
    override func start() {
        let vc = SetupViewController()
        vc.delegate = self
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
}

extension SetupCoordinator: SetupViewControllerDelegate {
    func setupViewControllerDismissed(_ viewController: SetupViewController) {
        delegate?.setupCoordinatorDidFinish(self)
    }
}
