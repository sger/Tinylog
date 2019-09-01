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
    
    private let router: Router
    
    weak var delegate: SetupCoordinatorDelegate?
    
    init(router: Router) {
        self.router = router
    }
    
    override func start() {
        let viewController = SetupViewController()
        viewController.delegate = self
        let nc = UINavigationController(rootViewController: viewController)
        nc.modalPresentationStyle = .fullScreen
        router.present(nc, animated: true)
    }
}

extension SetupCoordinator: SetupViewControllerDelegate {
    func setupViewControllerDismissed(_ viewController: SetupViewController) {
        delegate?.setupCoordinatorDidFinish(self)
        router.dismiss(animated: true)
    }
}
