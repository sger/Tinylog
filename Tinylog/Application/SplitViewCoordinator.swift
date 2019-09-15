//
//  SplitViewCoordinator.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 28/08/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import CoreData
import SVProgressHUD

final class SplitViewCoordinator: BaseCoordinator {

    private let window: UIWindow
    private let managedObjectContext: NSManagedObjectContext
    private let listsViewController: ListsViewController
    private let tasksViewController: TasksViewController
    private let splitViewController: UISplitViewController

    // swiftlint:disable force_cast
    var rootNavigationController: UINavigationController {
        return splitViewController.viewControllers[0] as! UINavigationController
    }

    init(window: UIWindow, managedObjectContext: NSManagedObjectContext) {
        self.window = window
        self.managedObjectContext = managedObjectContext
        self.splitViewController = UISplitViewController()
        self.listsViewController = ListsViewController(managedObjectContext: managedObjectContext)
        self.tasksViewController = TasksViewController(managedObjectContext: managedObjectContext)
    }

    override func start() {

        let masterNC: UINavigationController = UINavigationController(rootViewController: listsViewController)
        let detailNC: UINavigationController = UINavigationController(rootViewController: tasksViewController)
        
        tasksViewController.navigationItem.leftItemsSupplementBackButton = true
        tasksViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem

        listsViewController.delegate = self
        tasksViewController.delegate = self

        splitViewController.viewControllers = [masterNC, detailNC]
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .allVisible

        window.rootViewController = splitViewController
        window.backgroundColor = UIColor(named: "mainColor")
        window.makeKeyAndVisible()

        if Environment.current.userDefaults.bool(forKey: EnvUserDefaults.setupScreen) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.showSetup()
            }
        }
    }

    private func showSetup() {
        let navigationRouter = NavigationRouter(navigationController: rootNavigationController)
        let coordinator = SetupCoordinator(router: navigationRouter)
        coordinator.delegate = self
        add(coordinator)
        coordinator.start()
    }

    private func showSettings() {
        let navigationRouter = NavigationRouter(navigationController: rootNavigationController)
        let coordinator = SettingsCoordinator(router: navigationRouter, navigationController: rootNavigationController)
        coordinator.delegate = self
        add(coordinator)
        coordinator.start()
    }

    private func showAddListView(_ list: TLIList?, mode: AddListViewController.Mode) {
        let navigationRouter = NavigationRouter(navigationController: rootNavigationController)
        let coordinator = AddListViewCoordinator(navigationController: navigationRouter,
                                                 managedObjectContext: managedObjectContext,
                                                 list: list,
                                                 mode: mode)
        coordinator.delegate = self
        add(coordinator)
        coordinator.start()
    }

    private func showArchives() {
        let navigationRouter = NavigationRouter(navigationController: rootNavigationController)
        let coordinator = ArchivesCoordinator(router: navigationRouter, managedObjectContext: managedObjectContext)
        coordinator.delegate = self
        add(coordinator)
        coordinator.start()
    }
    
    private func showArchiveTasks(_ list: TLIList) {
        let navigationRouter = NavigationRouter(navigationController: rootNavigationController)
        let coordinator = ArchiveTasksCoordinator(router: navigationRouter, managedObjectContext: managedObjectContext, list: list)
        coordinator.onDismissed = { [weak self, weak coordinator] in
            self?.remove(coordinator)
        }
        add(coordinator)
        coordinator.start()
    }

    private func showDetailViewController(_ managedObjectContext: NSManagedObjectContext, list: TLIList) {
        tasksViewController.list = list
        
        let isIPad = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)

        if isIPad {
            tasksViewController.resetAddTaskView()
        }
        
        if let navigationController = tasksViewController.navigationController {
            splitViewController.showDetailViewController(navigationController, sender: nil)
        }
    }
}

extension SplitViewCoordinator: AddListViewCoordinatorDelegate {
    func addListViewCoordinatorDismissed(_ coordinator: Coordinator, list: TLIList) {
        listsViewController.selectTableViewCell(with: list)
        showDetailViewController(managedObjectContext, list: list)
        remove(coordinator)
    }
    
    func addListViewCoordinatorDidTapCancel(_ coordinator: Coordinator) {
        remove(coordinator)
    }
}

extension SplitViewCoordinator: ListsViewControllerDelegate {
    func listsViewControllerDidTapArchives(_ viewController: ListsViewController) {
        showArchives()
    }

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

extension SplitViewCoordinator: TasksViewControllerDelegate {
    func tasksViewControllerDidTapArchives(_ viewController: TasksViewController, list: TLIList?) {
        if let list = list {
            showArchiveTasks(list)
        } else {
            SVProgressHUD.show()
            SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
            SVProgressHUD.setBackgroundColor(UIColor.tinylogMainColor)
            SVProgressHUD.setForegroundColor(UIColor.white)
            SVProgressHUD.setFont(UIFont(name: "HelveticaNeue", size: 14.0)!)
            SVProgressHUD.showError(withStatus: "Please select a list")
        }
    }
}

extension SplitViewCoordinator: SettingsCoordinatorDelegate {
    func settingsCoordinatorDidFinish(_ coordinator: Coordinator) {
        remove(coordinator)
    }
}

// MARK: - SetupCoordinatorDelegate

extension SplitViewCoordinator: SetupCoordinatorDelegate {
    func setupCoordinatorDidFinish(_ coordinator: Coordinator) {
        remove(coordinator)
    }
}

extension SplitViewCoordinator: ArchivesCoordinatorDelegate {
    func archivesCoordinatorDidTapClose(_ coordinator: Coordinator) {
        remove(coordinator)
    }
}

// MARK: - UISplitViewControllerDelegate

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
