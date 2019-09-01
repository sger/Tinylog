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
//        navigationController.present(nc, animated: true, completion: nil)
        router.present(nc, animated: true)
//        router.push(vc, animated: true)
    }
}

extension SettingsCoordinator: SettingsTableViewControllerDelegate {
    func settingsTableViewControllerDidTapButton() {
        print("!!!!!!!!")
        delegate?.settingsCoordinatorDidFinish(self)
//        navigationController.dismiss(animated: true, completion: nil)
        router.dismiss(animated: true)
//        router.pop(animated: true)
    }
}
