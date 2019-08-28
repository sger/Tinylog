//
//  SplitViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import CoreData

extension UISplitViewController {
    convenience init(masterViewController: UIViewController, detailViewController: UIViewController) {
        self.init()
        viewControllers = [masterViewController, detailViewController]
    }
    
    var masterViewController: UIViewController? {
        return viewControllers.first
    }
    
    var detailViewController: UIViewController? {
        guard viewControllers.count == 2 else { return nil }
        return viewControllers.last
    }
}

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    private let managedObjectContext: NSManagedObjectContext
    var listsViewController: ListsViewController?
    var listViewController: TasksViewController?
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    /*
 guard let splitViewController = window?.rootViewController as? UISplitViewController,
 let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
 let masterViewController = leftNavController.topViewController as? MasterViewController,
 let rightNavController = splitViewController.viewControllers.last as? UINavigationController,
 let detailViewController = rightNavController.topViewController as? DetailViewController
 else { fatalError() }
 
 let firstMonster = masterViewController.monsters.first
 detailViewController.monster = firstMonster
 
 masterViewController.delegate = detailViewController
 
 detailViewController.navigationItem.leftItemsSupplementBackButton = true
 detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem*/
    
    private func setup() {
        // Master view controller
        listsViewController = ListsViewController()
        listsViewController?.managedObjectContext = managedObjectContext
        // Detail view controller
        listViewController = TasksViewController()
        
        // swiftlint:disable force_unwrapping
        let masterNC: UINavigationController = UINavigationController(rootViewController: listsViewController!)
        let detailNC: UINavigationController = UINavigationController(rootViewController: listViewController!)
        
        let masterViewController = masterNC.topViewController as? ListsViewController
        let detailViewController = detailNC.topViewController as? TasksViewController
        
        masterViewController?.delegate = detailViewController
        
        print("detailViewController \(String(describing: detailViewController))")
        
        self.viewControllers = [masterNC, detailNC]
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }
    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        listsViewController = ListsViewController()
//        listsViewController?.managedObjectContext = AppDelegate.sharedAppDelegate().coreDataManager.managedObjectContext
//        listViewController = TasksViewController()
//
//        // swiftlint:disable force_unwrapping
//        let listsVC: UINavigationController = UINavigationController(rootViewController: listsViewController!)
//        let listVC: UINavigationController = UINavigationController(rootViewController: listViewController!)
//
//        self.viewControllers = [listsVC, listVC]
//        self.delegate = self
//        self.preferredDisplayMode = .allVisible
//    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class func sharedSplitViewController() -> SplitViewController {
        guard let splitViewController = AppDelegate.sharedAppDelegate().window?.rootViewController
            as? SplitViewController else {
            fatalError()
        }
        return splitViewController
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
