//
//  AppDelegate.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 16/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import Reachability
import Ensembles
import Firebase

/// TLIAppDelegate Application Logic.
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CDEPersistentStoreEnsembleDelegate {

    /// The instance of the UIWindow.
    var window: UIWindow?

    /// Access core data managed object context.
    let coreDataManager = CoreDataManager(model: "Tinylog")

    var applicationCoordinator: ApplicationCoordinator!

    /**
        Singleton of TLIAppDelegate

     - Returns: TLIAppDelegate instance.
     */
    class func sharedAppDelegate() -> AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return delegate
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
        -> Bool {

        // Use verbose logging for sync
        // CDESetCurrentLoggingLevel(CDELoggingLevel.verbose.rawValue)

        // Register defaults

        Environment.current.userDefaults.register(defaults:
            [String(kTLIFontDefaultsKey): kTLIFontHelveticaNeueKey,
            EnvUserDefaults.syncMode: false,
            EnvUserDefaults.fontSize: 17.0,
            EnvUserDefaults.setupScreen: true])

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

        self.window = UIWindow(frame: UIScreen.main.bounds)

        applicationCoordinator = ApplicationCoordinator(window: window!, managedObjectContext: coreDataManager.managedObjectContext)
        applicationCoordinator.start()

        // Change color cursor for UITextField
        UITextField.appearance().tintColor = UIColor.tinylogMainColor

        let navigationBar: UINavigationBar = UINavigationBar.appearance()
        navigationBar.barTintColor = UIColor.tinylogNavigationBarDayColor
        navigationBar.tintColor = UIColor.tinylogMainColor

        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.mediumFontWithSize(18.0),
            NSAttributedString.Key.foregroundColor: UIColor.tinylogTextColor]

        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

        // Setup for notifications
        registerNotifications()

        _ = ReachabilityManager.instance

        return true
    }

    deinit {
        unregisterNotifications()
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
}

// MARK: Notifications

extension AppDelegate {
    fileprivate func registerNotifications() {
    }

    fileprivate func unregisterNotifications() {
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
	return UIBackgroundTaskIdentifier(rawValue: input)
}
