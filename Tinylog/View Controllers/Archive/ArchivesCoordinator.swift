//
//  ArchivesCoordinator.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 31/08/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

protocol ArchivesCoordinatorDelegate: AnyObject {
    func archivesCoordinatorDidFinish(_ coordinator: Coordinator)
}

final class ArchivesCoordinator: BaseCoordinator {

    private let router: Router
    private let managedObjectContext: NSManagedObjectContext

    weak var delegate: ArchivesCoordinatorDelegate?

    var onDismissed: (() -> Void)?

    init(router: Router,
         managedObjectContext: NSManagedObjectContext) {
        self.router = router
        self.managedObjectContext = managedObjectContext
    }

    override func start() {
        let archivesViewController = ArchivesViewController(managedObjectContext: managedObjectContext)
        archivesViewController.onTapCloseButton = { [weak self] in
            print("hide")
            self?.router.dismiss(animated: true)
            self?.onDismissed?()
        }
        archivesViewController.delegate = self
        let nc = UINavigationController(rootViewController: archivesViewController)
        nc.modalPresentationStyle = .formSheet
        router.present(nc, animated: true, completion: nil)
    }
}

extension ArchivesCoordinator: ArchivesViewControllerDelegate {
    func achivesViewViewControllerDidTapButton() {
        delegate?.archivesCoordinatorDidFinish(self)
        router.dismiss(animated: true)
    }
}
