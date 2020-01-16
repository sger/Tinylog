//
//  ArchivedListsCoordinator.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 31/08/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

protocol ArchivesCoordinatorDelegate: AnyObject {
    func archivesCoordinatorDidTapClose(_ coordinator: Coordinator)
}

final class ArchivedListsCoordinator: BaseCoordinator {

    private let router: Router
    private let managedObjectContext: NSManagedObjectContext

    weak var delegate: ArchivesCoordinatorDelegate?

    init(router: Router,
         managedObjectContext: NSManagedObjectContext) {
        self.router = router
        self.managedObjectContext = managedObjectContext
    }

    override func start() {
        let archivesViewController = ArchivedListsViewController(managedObjectContext: managedObjectContext)
        archivesViewController.delegate = self
        let nc = UINavigationController(rootViewController: archivesViewController)
        nc.modalPresentationStyle = .fullScreen
        router.present(nc, animated: true, completion: nil)
    }
}

extension ArchivedListsCoordinator: ArchivedListsViewControllerDelegate {
    func archivedListsViewControllerDidTapButton() {
        router.dismiss(animated: true, completion: nil)
        delegate?.archivesCoordinatorDidTapClose(self)
    }
}
