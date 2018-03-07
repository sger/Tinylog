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
import Mixpanel
import Fabric
import Crashlytics
import Ensembles

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
    var managedObjectContext: NSManagedObjectContext!

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
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
        -> Bool {

        // Use verbose logging for sync
        // CDESetCurrentLoggingLevel(CDELoggingLevel.verbose.rawValue)

        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem]
            as? UIApplicationShortcutItem {

            handleShortcut(shortcutItem)
            return false
        }

        // Register defaults

        if #available(iOS 9, *) {
            let standardDefaults = UserDefaults.standard
            standardDefaults.register(defaults: [
                String(kTLIFontDefaultsKey): kTLIFontSanFranciscoKey,
                String(TLIUserDefaults.kTLISyncMode): "off",
                "kFontSize": 17.0,
                "kSystemFontSize": "off",
                "kSetupScreen": "on"])
        } else {
            let standardDefaults = UserDefaults.standard
            standardDefaults.register(defaults: [
                String(kTLIFontDefaultsKey): kTLIFontHelveticaNeueKey,
                String(TLIUserDefaults.kTLISyncMode): "off",
                "kFontSize": 17.0,
                "kSystemFontSize": "off",
                "kSetupScreen": "on"])
        }

        do {
            try FileManager.default.createDirectory(
                at: storeDirectoryURL as URL,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch {
            fatalError("Cannot create directory \(error)")
        }

        // Setup Core Data Stack
        setupCoreData()

        let syncManager: TLISyncManager = TLISyncManager.shared()
        syncManager.managedObjectContext = managedObjectContext
        syncManager.storePath = storeURL.path
        syncManager.setup()

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSManagedObjectContextDidSave,
            object: managedObjectContext,
            queue: nil) { (_) -> Void in
                syncManager.synchronize(completion: nil)
            }

        Crashlytics.start(withAPIKey: Secrets.crashlyticsKey)
        Mixpanel.sharedInstance(withToken: Secrets.mixpanelToken)
        SGReachabilityController.shared()

        self.window = UIWindow(frame: UIScreen.main.bounds)

        let IS_IPAD = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)

        if  IS_IPAD {
            let splitViewController = TLISplitViewController()
            self.window?.rootViewController = splitViewController
            TLIAnalyticsTracker.trackMixpanelEvent("Open App", properties: ["device": "ipad"])
        } else {
            let listsViewController: TLIListsViewController = TLIListsViewController()
            listsViewController.managedObjectContext = managedObjectContext
            let nc: UINavigationController = UINavigationController(rootViewController: listsViewController)
            self.window?.rootViewController = nc
            TLIAnalyticsTracker.trackMixpanelEvent("Open App", properties: ["device": "iphone"])
        }

        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()

        // Change color cursor for UITextField
        UITextField.appearance().tintColor = UIColor.tinylogMainColor

        let navigationBar: UINavigationBar = UINavigationBar.appearance()
        navigationBar.barTintColor = UIColor.tinylogNavigationBarDayColor
        navigationBar.tintColor = UIColor.tinylogMainColor

        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.mediumFontWithSize(18.0),
            NSAttributedStringKey.foregroundColor: UIColor.tinylogTextColor]

        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)

        if let displaySetupScreen = UserDefaults.standard.object(forKey: "kSetupScreen") as? String {
            if displaySetupScreen == "on" {
                //Setup Mixpanel
                if let mixpanel = Mixpanel.sharedInstance() {
                    TLIAnalyticsTracker.createAlias(mixpanel.distinctId)
                }
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
        var identifier: UIBackgroundTaskIdentifier = 0
        identifier = UIApplication.shared.beginBackgroundTask(expirationHandler: { () -> Void in
        })
        DispatchQueue.main.async {
            // swiftlint:disable force_try
            try! self.managedObjectContext.save()
            TLISyncManager.shared().synchronize(completion: { (_) -> Void in
                UIApplication.shared.endBackgroundTask(identifier)
            })
        }

        UIApplication.shared.applicationIconBadgeNumber =  0
        Mixpanel.sharedInstance()?.flush()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {
        TLISyncManager.shared().synchronize(completion: nil)
        UIApplication.shared.applicationIconBadgeNumber =  0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        try! managedObjectContext.save()
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
                if let vc = navigationController.viewControllers[0] as? TLIListsViewController {
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

// MARK: Core Data Stack

extension TLIAppDelegate {

    var storeDirectoryURL: URL {
        // swiftlint:disable force_try
        return try! FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true)
    }

    var storeURL: URL {
        return self.storeDirectoryURL.appendingPathComponent("store.sqlite")
    }

    fileprivate func setupCoreData() {
        if let modelURL = Bundle.main.url(forResource: "Tinylog", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL) {
            try! FileManager.default.createDirectory(
                at: self.storeDirectoryURL,
                withIntermediateDirectories: true,
                attributes: nil)

            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true]
            try! coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: self.storeURL,
                options: options)

            managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = coordinator
            managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }
    }
}
