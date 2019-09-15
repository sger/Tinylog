//
//  ArchivedTasksCoordinator.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 08/09/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import Foundation

protocol ArchiveTasksCoordinatorDelegate: AnyObject {
    func archivesCoordinatorDidFinish(_ coordinator: Coordinator)
}

final class ArchivedTasksCoordinator: BaseCoordinator {

    private let router: Router
    private let managedObjectContext: NSManagedObjectContext
    private let list: TLIList

    var onDismissed: (() -> Void)?

    init(router: Router,
         managedObjectContext: NSManagedObjectContext,
         list: TLIList) {
        self.router = router
        self.managedObjectContext = managedObjectContext
        self.list = list
    }

    override func start() {        
        let viewController: ArchivedTasksViewController = ArchivedTasksViewController()
        viewController.managedObjectContext = managedObjectContext
        viewController.list = list
        viewController.onTapCloseButton = { [weak self] in
            self?.router.dismiss(animated: true, completion: nil)
            self?.onDismissed?()
        }
        
        let nc: UINavigationController = UINavigationController(rootViewController: viewController)
        nc.modalPresentationStyle = .fullScreen
        router.present(nc, animated: true, completion: nil)
    }
}

