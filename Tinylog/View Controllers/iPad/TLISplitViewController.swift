//
//  TLISplitViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLISplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    var listsViewController: TLIListsViewController?
    var listViewController: TLITasksViewController?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        listsViewController = TLIListsViewController()
        listsViewController?.managedObjectContext = TLIAppDelegate.sharedAppDelegate().coreDataManager.managedObjectContext
        listViewController = TLITasksViewController()

        // swiftlint:disable force_unwrapping
        let listsVC: UINavigationController = UINavigationController(rootViewController: listsViewController!)
        let listVC: UINavigationController = UINavigationController(rootViewController: listViewController!)

        self.viewControllers = [listsVC, listVC]
        self.delegate = self
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class func sharedSplitViewController() -> TLISplitViewController {
        guard let splitViewController = TLIAppDelegate.sharedAppDelegate().window?.rootViewController
            as? TLISplitViewController else {
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
}
