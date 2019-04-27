//
//  TLIAppDelegate.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 16/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import Reachability
import SGReachability
import Ensembles
import Firebase

/// TLIAppDelegate Application Logic.
@UIApplicationMain
class TLIAppDelegate: UIResponder, UIApplicationDelegate, CDEPersistentStoreEnsembleDelegate {

    /**
     Identifier for 3d Touch.

     - CreateNewList: Create a new list.
     */
    enum ShortcutIdentifier: String {

        case createNewList
        init?(fullIdentifier: String) {
            guard let shortIdentifier = fullIdentifier.components(separatedBy: ".").last else {
                return nil
            }
            self.init(rawValue: shortIdentifier)
        }
    }

    /// The instance of the UIWindow.
    var window: UIWindow?

    /// Access globally network status.
    var networkMode: String?

    /// Access core data managed object context.
    let coreDataManager = CoreDataManager(model: "Tinylog")

    /**
        Singleton of TLIAppDelegate

     - Returns: TLIAppDelegate instance.
     */
    class func sharedAppDelegate() -> TLIAppDelegate {
        guard let delegate = UIApplication.shared.delegate as? TLIAppDelegate else {
            fatalError()
        }
        return delegate
    }

    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {

        completionHandler(handleShortcut(shortcutItem))
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
        -> Bool {

        // Use verbose logging for sync
        // CDESetCurrentLoggingLevel(CDELoggingLevel.verbose.rawValue)

        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem]
            as? UIApplicationShortcutItem {

            handleShortcut(shortcutItem)
            return false
        }

        // Register defaults

        Environment.current.userDefaults.register(defaults:
            [String(kTLIFontDefaultsKey): kTLIFontHelveticaNeueKey,
            TLIUserDefaults.kTLISyncMode: false,
            TLIUserDefaults.kFontSize: 17.0,
            TLIUserDefaults.kSetupScreen: true])

        do {
            try FileManager.default.createDirectory(
                at: coreDataManager.storeDirectoryURL as URL,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch {
            fatalError("Cannot create directory \(error)")
        }

        // Setup Core Data Sync Manager

        let syncManager: TLISyncManager = TLISyncManager.shared()
        syncManager.managedObjectContext = coreDataManager.managedObjectContext
        syncManager.storePath = coreDataManager.storeURL.path
        syncManager.setup()

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSManagedObjectContextDidSave,
            object: coreDataManager.managedObjectContext,
            queue: nil) { (_) -> Void in
                syncManager.synchronize(completion: nil)
            }

        FirebaseApp.configure()
        SGReachabilityController.shared()

        self.window = UIWindow(frame: UIScreen.main.bounds)

        let IS_IPAD = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)

        if  IS_IPAD {
            let splitViewController = TLISplitViewController()
            self.window?.rootViewController = splitViewController
        } else {
            let listsViewController: ListsViewController = ListsViewController()
            listsViewController.managedObjectContext = coreDataManager.managedObjectContext//managedObjectContext
            let nc: UINavigationController = UINavigationController(rootViewController: listsViewController)
            self.window?.rootViewController = nc
        }

        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()

        // Change color cursor for UITextField
        UITextField.appearance().tintColor = UIColor.tinylogMainColor

        let navigationBar: UINavigationBar = UINavigationBar.appearance()
        navigationBar.barTintColor = UIColor.tinylogNavigationBarDayColor
        navigationBar.tintColor = UIColor.tinylogMainColor

        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.mediumFontWithSize(18.0),
            NSAttributedString.Key.foregroundColor: UIColor.tinylogTextColor]

        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

        if let displaySetupScreen = UserDefaults.standard.object(forKey: "kSetupScreen") as? String {
            if displaySetupScreen == "on" {
            }
        }

        // Setup for notifications
        registerNotifications()

        return true
    }

    deinit {
        unregisterNotifications()
    }

    @objc func reachabilityDidChange(_ notification: Notification) {
        if let reachability: Reachability = notification.object as? Reachability {
            if reachability.isReachable() {
                if reachability.isReachableViaWiFi() {
                    networkMode = "wifi"
                } else if reachability.isReachableViaWWAN() {
                    networkMode = "wwan"
                }
            } else {
                networkMode = "notReachable"
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {
        var identifier: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
        identifier = UIApplication.shared.beginBackgroundTask(expirationHandler: { () -> Void in
        })
        DispatchQueue.main.async {
            // swiftlint:disable force_try
            try! self.coreDataManager.managedObjectContext.save()
            TLISyncManager.shared().synchronize(completion: { (_) -> Void in
                UIApplication.shared.endBackgroundTask(
                    convertToUIBackgroundTaskIdentifier(identifier.rawValue))
            })
        }

        UIApplication.shared.applicationIconBadgeNumber =  0
    }

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {
        TLISyncManager.shared().synchronize(completion: nil)
        UIApplication.shared.applicationIconBadgeNumber =  0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        try! coreDataManager.managedObjectContext.save()
    }

    func application(
        _ application: UIApplication,
        performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        let syncManager: TLISyncManager = TLISyncManager.shared()
        if syncManager.canSynchronize() {
            syncManager.synchronize { (error) -> Void in
                if error != nil {
                    completionHandler(UIBackgroundFetchResult.failed)
                    if error?._code == 1003 {}
                } else {
                    completionHandler(UIBackgroundFetchResult.newData)
                }
            }
        }
    }

    @discardableResult fileprivate func handleShortcut(_ shortcutItem: UIApplicationShortcutItem) -> Bool {

        let shortcutType = shortcutItem.type
        guard let shortcutIdentifier = ShortcutIdentifier(fullIdentifier: shortcutType) else {
            return false
        }

        return selectTabBarItemForIdentifier(shortcutIdentifier)
    }

    fileprivate func selectTabBarItemForIdentifier(_ identifier: ShortcutIdentifier) -> Bool {
        switch identifier {
        case .createNewList:
            if let navigationController = window?.rootViewController as? UINavigationController {
                if let vc = navigationController.viewControllers[0] as? ListsViewController {
                    vc.addNewList(nil)
                }
            }
            return true
        }
    }
}

// MARK: Notifications

extension TLIAppDelegate {
    fileprivate func registerNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TLIAppDelegate.reachabilityDidChange(_:)),
            name: NSNotification.Name.reachabilityChanged,
            object: nil)
    }

    fileprivate func unregisterNotifications() {
        NotificationCenter.default.removeObserver(
            self, name: NSNotification.Name.reachabilityChanged,
            object: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
	return UIBackgroundTaskIdentifier(rawValue: input)
}
