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
    
    weak var delegate: SettingsCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() {
        let vc = SettingsTableViewController()
        vc.delegate = self
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        navigationController.present(nc, animated: true, completion: nil)
    }
}

extension SettingsCoordinator: SettingsTableViewControllerDelegate {
    func settingsTableViewControllerDidTapButton() {
        delegate?.settingsCoordinatorDidFinish(self)
        navigationController.dismiss(animated: true, completion: nil)
    }
}
