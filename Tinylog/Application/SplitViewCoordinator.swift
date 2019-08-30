//
//  SplitViewCoordinator.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 28/08/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import CoreData

final class SplitViewCoordinator: BaseCoordinator {
    
    private let window: UIWindow
    private let managedObjectContext: NSManagedObjectContext
    private let listsViewController: ListsViewController
    private let tasksViewController: TasksViewController
    private let splitViewController: UISplitViewController
    
    var folderNavigationController: UINavigationController {
        return splitViewController.viewControllers[0] as! UINavigationController
    }
    
    init(window: UIWindow, managedObjectContext: NSManagedObjectContext) {
        self.window = window
        self.managedObjectContext = managedObjectContext
        self.splitViewController = UISplitViewController()
        self.listsViewController = ListsViewController()
        self.listsViewController.managedObjectContext = self.managedObjectContext
        self.tasksViewController = TasksViewController()
    }
    
    override func start() {
        let masterNC: UINavigationController = UINavigationController(rootViewController: listsViewController)
        let detailNC: UINavigationController = UINavigationController(rootViewController: tasksViewController)
        
        listsViewController.delegate = self
        
        splitViewController.viewControllers = [masterNC, detailNC]
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .allVisible
        
        window.rootViewController = splitViewController
        window.backgroundColor = UIColor.white
        window.makeKeyAndVisible()
    }
    
    func showSettings() {
        let coordinator = SettingsCoordinator(navigationController: folderNavigationController)
        coordinator.delegate = self
        add(coordinator)
        coordinator.start()
    }
    
    func showAddListView(_ list: TLIList?, mode: AddListViewController.Mode) {
        let coordinator = AddListViewCoordinator(navigationController: folderNavigationController,
                                                 managedObjectContext: managedObjectContext,
                                                 list: list,
                                                 mode: mode)
        coordinator.delegate = self
        add(coordinator)
        coordinator.start()
    }
    
    func showDetailViewController(_ managedObjectContext: NSManagedObjectContext, list: TLIList) {
        tasksViewController.managedObjectContext = managedObjectContext
        tasksViewController.list = list
        splitViewController.showDetailViewController(tasksViewController, sender: nil)
    }
}

extension SplitViewCoordinator: AddListViewCoordinatorDelegate {
    func addListViewCoordinatorDismissed(_ coordinator: Coordinator, list: TLIList) {
        listsViewController.selectTableViewCell(with: list)
        showDetailViewController(managedObjectContext, list: list)
        remove(coordinator)
    }
}

extension SplitViewCoordinator: ListsViewControllerDelegate {
    func listsViewControllerDidAddList(_ viewController: ListsViewController,
                                       list: TLIList?,
                                       selectedMode mode: AddListViewController.Mode) {
        showAddListView(list, mode: mode)
    }
    
    func listsViewControllerDidTapSettings(_ viewController: ListsViewController) {
        showSettings()
    }
    
    func listsViewControllerDidTapList(_ viewController: ListsViewController, list: TLIList) {
        showDetailViewController(managedObjectContext, list: list)
    }
}

extension SplitViewCoordinator: SettingsCoordinatorDelegate {
    func settingsCoordinatorDidFinish(_ coordinator: Coordinator) {
        remove(coordinator)
    }
}

extension SplitViewCoordinator: UISplitViewControllerDelegate {
    
    func splitViewController(
        _ svc: UISplitViewController,
        shouldHide vc: UIViewController,
        in orientation: UIInterfaceOrientation) -> Bool {
        return false
    }
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
