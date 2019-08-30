//
//  ApplicationCoordinator.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 27/08/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import CoreData

final class ApplicationCoordinator: BaseCoordinator {
    
    private let window: UIWindow
    private let navigationController: UINavigationController
    private let managedObjectContext: NSManagedObjectContext
    
    init(window: UIWindow, managedObjectContext: NSManagedObjectContext) {
        self.window = window
        self.navigationController = UINavigationController()
        self.managedObjectContext = managedObjectContext
    }
    
    override func start() {
        if Environment.current.userDefaults.bool(forKey: EnvUserDefaults.setupScreen) {
            showSetup()
        } else {
            showSplitView()
        }
    }
    
    func showSplitView() {
        let coordinator = SplitViewCoordinator(window: window, managedObjectContext: managedObjectContext)
        add(coordinator)
        coordinator.start()
    }
    
    func showSetup() {
        let coordinator = SetupCoordinator(window: window, navigationController: navigationController)
        coordinator.delegate = self
        add(coordinator)
        coordinator.start()
    }
}

// MARK: - SetupCoordinatorDelegate

extension ApplicationCoordinator: SetupCoordinatorDelegate {
    func setupCoordinatorDidFinish(_ coordinator: Coordinator) {
        remove(coordinator)
        showSplitView()
    }
}
