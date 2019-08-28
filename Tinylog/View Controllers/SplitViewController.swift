//
//  SplitViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import CoreData

final class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    private let managedObjectContext: NSManagedObjectContext
    
    private var listsViewController: ListsViewController?
    private var tasksViewController: TasksViewController?
    
    var rootNavigationController: UINavigationController {
        return viewControllers[0] as! UINavigationController
    }
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    private func setup() {
        // Master view controller
        listsViewController = ListsViewController()
        listsViewController?.managedObjectContext = managedObjectContext
        // Detail view controller
        tasksViewController = TasksViewController()
        
        // swiftlint:disable force_unwrapping
        let masterNC: UINavigationController = UINavigationController(rootViewController: listsViewController!)
        let detailNC: UINavigationController = UINavigationController(rootViewController: tasksViewController!)
        
        let masterViewController = masterNC.topViewController as? ListsViewController
        let detailViewController = detailNC.topViewController as? TasksViewController
        
        masterViewController?.delegate = detailViewController
        
        self.viewControllers = [masterNC, detailNC]
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

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
