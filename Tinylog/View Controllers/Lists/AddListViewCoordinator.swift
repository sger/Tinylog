//
//  AddListViewCoordinator.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 28/08/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import CoreData

protocol AddListViewCoordinatorDelegate: AnyObject {
    func addListViewCoordinatorDismissed(_ coordinator: Coordinator, list: TLIList)
    func addListViewCoordinatorDidTapCancel(_ coordinator: Coordinator)
}

final class AddListViewCoordinator: BaseCoordinator {

    weak var delegate: AddListViewCoordinatorDelegate?
    private let router: Router
    private let managedObjectContext: NSManagedObjectContext
    private let list: TLIList?
    private let mode: AddListViewController.Mode

    init(navigationController: Router,
         managedObjectContext: NSManagedObjectContext,
         list: TLIList? = nil,
         mode: AddListViewController.Mode = .create) {
        self.router = navigationController
        self.managedObjectContext = managedObjectContext
        self.list = list
        self.mode = mode
    }

    override func start() {
        let addListViewController = AddListViewController(managedObjectContext: managedObjectContext,
                                                          list: list,
                                                          mode: mode)
        addListViewController.delegate = self
        let nc = UINavigationController(rootViewController: addListViewController)
        nc.modalPresentationStyle = .formSheet
        router.present(nc, animated: true, completion: nil)
    }
}

extension AddListViewCoordinator: AddListViewControllerDelegate {

    func addListViewController(_ viewController: AddListViewController, didSucceedWithList list: TLIList) {
        router.dismiss(animated: true) {
            self.delegate?.addListViewCoordinatorDismissed(self, list: list)
        }
    }

    func addListViewControllerDismissed(_ viewController: AddListViewController) {
        router.dismiss(animated: true, completion: nil)
        delegate?.addListViewCoordinatorDidTapCancel(self)
    }
}
