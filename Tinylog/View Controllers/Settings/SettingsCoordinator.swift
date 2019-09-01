//
//  SettingsCoordinator.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 27/08/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import Foundation

protocol SettingsCoordinatorDelegate: AnyObject {
    func settingsCoordinatorDidFinish(_ coordinator: Coordinator)
}

final class SettingsCoordinator: BaseCoordinator {
    
    private let navigationController: UINavigationController
    private let router: Router
    
    weak var delegate: SettingsCoordinatorDelegate?
    
    init(router: Router, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.router = router
    }
    
    override func start() {
        let vc = SettingsTableViewController()
        vc.delegate = self
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        router.present(nc, animated: true)
    }
}

extension SettingsCoordinator: SettingsTableViewControllerDelegate {
    func settingsTableViewControllerDidTapButton() {
        delegate?.settingsCoordinatorDidFinish(self)
        router.dismiss(animated: true)
    }
}
