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
    
    private let navigationController: UINavigationController
    private let router: Router
    
    weak var delegate: SetupCoordinatorDelegate?
    
    init(router: Router, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.router = router
    }
    
    override func start() {
        let vc = SetupViewController()
        vc.delegate = self
        let nc = UINavigationController(rootViewController: vc)
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
