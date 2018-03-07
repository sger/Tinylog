//
//  TLIListsViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_cast
// swiftlint:disable force_unwrapping
import UIKit
import CoreData
// Consider refactoring the code to use the non-optional operators.
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// Consider refactoring the code to use the non-optional operators.
private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class TLIListsViewController: TLICoreDataTableViewController,
    UITextFieldDelegate,
    TLIAddListViewControllerDelegate,
    UISearchBarDelegate,
    UISearchControllerDelegate,
    UISearchResultsUpdating {

    var managedObjectContext: NSManagedObjectContext!

    struct RestorationKeys {
        static let viewControllerTitle = "ViewControllerTitleKey"
        static let searchControllerIsActive = "SearchControllerIsActiveKey"
        static let searchBarText = "SearchBarTextKey"
        static let searchBarIsFirstResponder = "SearchBarIsFirstResponderKey"
    }

    // State restoration values.
    struct SearchControllerRestorableState {
        var wasActive = false
        var wasFirstResponder = false
    }

    var restoredState = SearchControllerRestorableState()

    let kEstimateRowHeight = 61
    let kCellIdentifier = "CellIdentifier"
    var editingIndexPath: IndexPath?
    var estimatedRowHeightCache: NSMutableDictionary?
    var resultsTableViewController: TLIResultsTableViewController?
    var searchController: UISearchController?
    var topBarView: UIView?
    var didSetupContraints = false

    var listsFooterView: TLIListsFooterView? = {
        let listsFooterView = TLIListsFooterView.newAutoLayout()
        return listsFooterView
    }()

    lazy var noListsLabel: UILabel? = {
        let noListsLabel: UILabel = UILabel.newAutoLayout()
        noListsLabel.font = UIFont.tinylogFontOfSize(16.0)
        noListsLabel.textColor = UIColor.tinylogTextColor
        noListsLabel.textAlignment = NSTextAlignment.center
        noListsLabel.text = "Tap + icon to create a new list."
        return noListsLabel
    }()

    func configureFetch() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "List")
        let positionDescriptor = NSSortDescriptor(key: "position", ascending: false)
        let titleDescriptor  = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, titleDescriptor]
        fetchRequest.predicate = NSPredicate(format: "archivedAt = nil")
        self.frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        self.frc?.delegate = self

        do {
            try self.frc?.performFetch()
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureFetch()

        self.title = "My Lists"

        self.view.backgroundColor = UIColor.tinylogLightGray
        self.tableView?.backgroundColor = UIColor.tinylogLightGray
        self.tableView?.backgroundView = UIView()
        self.tableView?.backgroundView?.backgroundColor = UIColor.clear
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView?.register(TLIListTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 61
        self.tableView?.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height - 50.0)

        resultsTableViewController = TLIResultsTableViewController()
        resultsTableViewController?.managedObjectContext = managedObjectContext
        resultsTableViewController?.tableView?.delegate = self
        searchController = UISearchController(searchResultsController: resultsTableViewController)
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.sizeToFit()
        searchController?.searchBar.backgroundColor = UIColor.tinylogLightGray
        searchController?.searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchController?.searchBar.setSearchFieldBackgroundImage(
            UIImage(named: "search-bar-bg-gray"),
            for: UIControlState())

        searchController?.searchBar.tintColor = UIColor.tinylogMainColor
        let searchField: UITextField = searchController?.searchBar.value(
            forKey: "searchField") as! UITextField
        searchField.textColor = UIColor.tinylogTextColor

        self.tableView?.tableHeaderView = searchController?.searchBar
        searchController?.delegate = self
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.searchBar.delegate = self

        let settingsImage: UIImage = UIImage(named: "740-gear-toolbar")!
        let settingsButton: UIButton = UIButton(type: UIButtonType.custom)
        settingsButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        settingsButton.setBackgroundImage(settingsImage, for: UIControlState())
        settingsButton.setBackgroundImage(settingsImage, for: UIControlState.highlighted)
        settingsButton.addTarget(
            self,
            action: #selector(TLIListsViewController.displaySettings(_:)),
            for: UIControlEvents.touchDown)

        let settingsBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: settingsButton)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = settingsBarButtonItem

        listsFooterView?.addListButton?.addTarget(
            self,
            action: #selector(TLIListsViewController.addNewList(_:)),
            for: UIControlEvents.touchDown)
        listsFooterView?.archiveButton?.addTarget(
            self,
            action: #selector(TLIListsViewController.displayArchive(_:)),
            for: UIControlEvents.touchDown)

        setEditing(false, animated: false)

        registerNotifications()

        definesPresentationContext = true
    }
    deinit {
        unregisterNotifications()
    }

    override func loadView() {
        super.loadView()
        view.addSubview(noListsLabel!)
        view.addSubview(listsFooterView!)
        view.setNeedsUpdateConstraints()
    }

    @objc func onChangeSize(_ notification: Notification) {
        self.tableView?.reloadData()
    }

    func checkForLists() {

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "List")
        let positionDescriptor = NSSortDescriptor(key: "position", ascending: false)
        let titleDescriptor  = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, titleDescriptor]
        fetchRequest.predicate = NSPredicate(format: "archivedAt = nil")

        do {
            let results = try managedObjectContext.fetch(fetchRequest)

            if results.isEmpty {
                self.noListsLabel?.isHidden = false
            } else {
                self.noListsLabel?.isHidden = true
            }
        } catch let error  as NSError {
            fatalError(error.localizedDescription)
        }
    }

    override func updateViewConstraints() {

        if !didSetupContraints {

            noListsLabel?.autoCenterInSuperview()

            listsFooterView?.autoMatch(.width, to: .width, of: self.view)
            listsFooterView?.autoSetDimension(.height, toSize: 51.0)
            listsFooterView?.autoPinEdge(toSuperviewEdge: .left)
            listsFooterView?.autoPinEdge(toSuperviewEdge: .bottom)

            didSetupContraints = true
        }
        super.updateViewConstraints()
    }

    @objc func appBecomeActive() {
        startSync()
    }

    func startSync() {
        let syncManager: TLISyncManager = TLISyncManager.shared()
        if syncManager.canSynchronize() {
            syncManager.synchronize { (_) -> Void in
            }
        }
    }

    @objc func updateFonts() {
        self.tableView?.reloadData()
    }

    @objc func syncActivityDidEndNotification(_ notification: Notification) {
        if TLISyncManager.shared().canSynchronize() {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            let dateFormatter = DateFormatter()
            dateFormatter.formatterBehavior = DateFormatter.Behavior.behavior10_4
            dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.timeStyle = DateFormatter.Style.short

            //check for connectivity
            if TLIAppDelegate.sharedAppDelegate().networkMode == "notReachable" {
                listsFooterView?.updateInfoLabel("Offline")
            } else {
                listsFooterView?.updateInfoLabel(
                    NSString(
                        format: "Last Updated %@", dateFormatter.string(for: Date())!) as String)
            }

            checkForLists()

            self.tableView?.reloadData()
        }
    }

    @objc func syncActivityDidBeginNotification(_ notification: Notification) {
        if TLISyncManager.shared().canSynchronize() {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true

            if TLIAppDelegate.sharedAppDelegate().networkMode == "notReachable" {
                listsFooterView?.updateInfoLabel("Offline")
            } else {
                listsFooterView?.updateInfoLabel("Syncing...")
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            // Code here will execute before the rotation begins.
            // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
            coordinator.animate(alongsideTransition: { (_) -> Void in
                // Place code here to perform animations during the rotation.
                // You can pass nil for this closure if not necessary.
            }, completion: { (_) -> Void in
                self.tableView?.reloadData()
                self.view.setNeedsUpdateConstraints()
            })
    }

    @objc func addNewList(_ sender: UIButton?) {
        let addListViewController: TLIAddListViewController = TLIAddListViewController()
        addListViewController.managedObjectContext = managedObjectContext
        addListViewController.delegate = self
        addListViewController.mode = "create"
        let nc: UINavigationController = UINavigationController(rootViewController: addListViewController)
        nc.modalPresentationStyle = UIModalPresentationStyle.formSheet
        self.navigationController?.present(nc, animated: true, completion: nil)
        TLIAnalyticsTracker.trackMixpanelEvent("Add New List", properties: nil)
    }

    // MARK: Display Setup
    func displaySetup() {
        let setupViewController: TLISetupViewController = TLISetupViewController()
        let nc: UINavigationController = UINavigationController(rootViewController: setupViewController)
        nc.modalPresentationStyle = UIModalPresentationStyle.formSheet
        self.navigationController?.present(nc, animated: true, completion: nil)
        TLIAnalyticsTracker.trackMixpanelEvent("Setup", properties: nil)
    }

    @objc func displayArchive(_ button: TLIArchiveButton) {
        let archiveViewController: TLIArchiveViewController = TLIArchiveViewController()
        archiveViewController.managedObjectContext = managedObjectContext
        let nc: UINavigationController = UINavigationController(rootViewController: archiveViewController)
        nc.modalPresentationStyle = UIModalPresentationStyle.formSheet
        self.navigationController?.present(nc, animated: true, completion: nil)
        TLIAnalyticsTracker.trackMixpanelEvent("Display Archive", properties: nil)
    }

    // MARK: Display Settings

    @objc func displaySettings(_ sender: UIButton) {
        let settingsViewController: TLISettingsTableViewController = TLISettingsTableViewController()
        let nc: UINavigationController = UINavigationController(rootViewController: settingsViewController)
        nc.modalPresentationStyle = UIModalPresentationStyle.formSheet
        self.navigationController?.present(nc, animated: true, completion: nil)
        TLIAnalyticsTracker.trackMixpanelEvent("Display Settings", properties: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Restore the searchController's active state.
        if restoredState.wasActive {
            searchController!.isActive = restoredState.wasActive
            restoredState.wasActive = false

            if restoredState.wasFirstResponder {
                searchController!.searchBar.becomeFirstResponder()
                restoredState.wasFirstResponder = false
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setEditing(false, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        checkForLists()

        let userDefaults = UserDefaults.standard
        let displaySetupScreen: NSString = userDefaults.object(forKey: "kSetupScreen") as! NSString

        if displaySetupScreen == "on" {
            Utils.delay(0.1, closure: { () -> Void in
                self.displaySetup()
            })
        } else if displaySetupScreen == "off" {
            startSync()
        }
        if tableView!.indexPathForSelectedRow != nil {
            tableView?.deselectRow(at: tableView!.indexPathForSelectedRow!, animated: animated)
        }
        initEstimatedRowHeightCacheIfNeeded()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Done",
                style: UIBarButtonItemStyle.plain,
                target: self,
                action: #selector(TLIListsViewController.toggleEditMode(_:)))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Edit",
                style: UIBarButtonItemStyle.plain,
                target: self,
                action: #selector(TLIListsViewController.toggleEditMode(_:)))
        }
    }

    @objc func toggleEditMode(_ sender: UIBarButtonItem) {
        setEditing(!isEditing, animated: true)
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editRowAction = UITableViewRowAction(
            style: UITableViewRowActionStyle.default,
            title: "Edit", handler: {_, indexpath in

                let list: TLIList = self.frc?.object(at: indexpath) as! TLIList

                let addListViewController: TLIAddListViewController = TLIAddListViewController()
                addListViewController.managedObjectContext = self.managedObjectContext
                addListViewController.delegate = self
                addListViewController.list = list
                addListViewController.mode = "edit"
                let nc: UINavigationController = UINavigationController(
                    rootViewController: addListViewController)
                nc.modalPresentationStyle = UIModalPresentationStyle.formSheet
                self.navigationController?.present(nc, animated: true, completion: nil)
        })
        editRowAction.backgroundColor = UIColor.tinylogEditRowAction
        let archiveRowAction = UITableViewRowAction(
            style: UITableViewRowActionStyle.default,
            title: "Archive",
            handler: {_, indexpath in
                let list: TLIList = self.frc?.object(at: indexpath) as! TLIList
                list.archivedAt = Date()
                // swiftlint:disable force_try
                try! self.managedObjectContext.save()
                self.checkForLists()
        })
        archiveRowAction.backgroundColor = UIColor.tinylogMainColor
        return [archiveRowAction, editRowAction]
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func listAtIndexPath(_ indexPath: IndexPath) -> TLIList? {
        let list = self.frc?.object(at: indexPath) as! TLIList!
        return list
    }

    func updateList(_ list: TLIList, sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        var fetchedLists: [AnyObject] = self.frc?.fetchedObjects as [AnyObject]!

        // Remove current list item
        fetchedLists = fetchedLists.filter { $0 as! TLIList != list }

        var sortedIndex = destinationIndexPath.row

        for sectionIndex in 0..<destinationIndexPath.section {
            sortedIndex += (self.frc?.sections?[sectionIndex].numberOfObjects)!

            if sectionIndex == sourceIndexPath.section {
                sortedIndex -= 1
            }
        }

        fetchedLists.insert(list, at: sortedIndex)

        for(index, list) in fetchedLists.enumerated() {
            let tmpList = list as! TLIList
            tmpList.position = fetchedLists.count-index as NSNumber
        }
    }

    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        if sourceIndexPath.row == destinationIndexPath.row {
            return
        }

        // Disable fetched results controller

        self.ignoreNextUpdates = true

        let list = self.listAtIndexPath(sourceIndexPath)!

        updateList(list, sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)

        // swiftlint:disable force_try
        try! managedObjectContext.save()
    }

    func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return floor(getEstimatedCellHeightFromCache(indexPath, defaultHeight: 61)!)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier) as! TLIListTableViewCell
        self.configureCell(cell, atIndexPath: indexPath)

        let success = isEstimatedRowHeightInCache(indexPath)

        if success != nil {
            let cellSize: CGSize = cell.systemLayoutSizeFitting(
                CGSize(width: self.view.frame.size.width, height: 0),
                withHorizontalFittingPriority: UILayoutPriority(rawValue: 1000),
                verticalFittingPriority: UILayoutPriority(rawValue: 61))
            putEstimatedCellHeightToCache(indexPath, height: cellSize.height)
        }
        return cell
    }

    override func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let list: TLIList = self.frc?.object(at: indexPath) as! TLIList
        let listTableViewCell: TLIListTableViewCell = cell as! TLIListTableViewCell
        listTableViewCell.currentList = list
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var list: TLIList

        if tableView == self.tableView {
            list = self.frc?.object(at: indexPath) as! TLIList
        } else {
            list = resultsTableViewController?.frc?.object(at: indexPath) as! TLIList
        }

        let IS_IPAD = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
        // swiftlint:disable line_length
        if  IS_IPAD {
            TLISplitViewController.sharedSplitViewController().listViewController?.managedObjectContext = managedObjectContext
            TLISplitViewController.sharedSplitViewController().listViewController?.managedObject = list
            TLISplitViewController.sharedSplitViewController().listViewController?.title = list.title
        } else {
            let tasksViewController: TLITasksViewController = TLITasksViewController()
            tasksViewController.managedObjectContext = managedObjectContext
            tasksViewController.list = list
            self.navigationController?.pushViewController(tasksViewController, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: IndexPath) -> String! {
        return "Delete"
    }

    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle != UITableViewCellEditingStyle.delete {
            return
        }

        let list: TLIList = self.frc?.object(at: indexPath) as! TLIList

        managedObjectContext.delete(list)

        try! managedObjectContext.save()
    }

    func performBackgroundUpdates(_ completionHandler: ((UIBackgroundFetchResult) -> Void)!) {
        completionHandler(UIBackgroundFetchResult.newData)
    }

    func onClose(_ addListViewController: TLIAddListViewController, list: TLIList) {

        let indexPath = self.frc?.indexPath(forObject: list)
        self.tableView?.selectRow(at: indexPath!, animated: true, scrollPosition: UITableViewScrollPosition.none)

        let IS_IPAD = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
        // swiftlint:disable line_length
        if IS_IPAD {
            TLISplitViewController.sharedSplitViewController().listViewController?.managedObjectContext = managedObjectContext
            TLISplitViewController.sharedSplitViewController().listViewController?.managedObject = list
        } else {
            let tasksViewController: TLITasksViewController = TLITasksViewController()
            tasksViewController.managedObjectContext = managedObjectContext
            tasksViewController.list = list
            tasksViewController.focusTextField = true
            self.navigationController?.pushViewController(tasksViewController, animated: true)
        }

       checkForLists()
    }

    func putEstimatedCellHeightToCache(_ indexPath: IndexPath, height: CGFloat) {
        initEstimatedRowHeightCacheIfNeeded()
        estimatedRowHeightCache?.setValue(height, forKey: NSString(format: "%ld", indexPath.row) as String)
    }

    func initEstimatedRowHeightCacheIfNeeded() {
        if estimatedRowHeightCache == nil {
            estimatedRowHeightCache = NSMutableDictionary()
        }
    }

    func getEstimatedCellHeightFromCache(_ indexPath: IndexPath, defaultHeight: CGFloat) -> CGFloat? {
        initEstimatedRowHeightCacheIfNeeded()

        let height: CGFloat? = estimatedRowHeightCache!.value(
            forKey: NSString(format: "%ld", indexPath.row) as String) as? CGFloat

        if height != nil {
            return floor(height!)
        }
        return defaultHeight
    }

    func isEstimatedRowHeightInCache(_ indexPath: IndexPath) -> Bool? {
        let value = getEstimatedCellHeightFromCache(indexPath, defaultHeight: 0)
        if value > 0 {
            return true
        }
        return false
    }

    // MARK: UISearchBarDelegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        resultsTableViewController?.frc?.delegate = nil
        resultsTableViewController?.frc = nil
    }

    // MARK: UISearchControllerDelegate

    func presentSearchController(_ searchController: UISearchController) {}

    func willPresentSearchController(_ searchController: UISearchController) {
        topBarView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 20.0))
        topBarView?.backgroundColor = UIColor.tinylogLightGray
        TLIAppDelegate.sharedAppDelegate().window?.rootViewController?.view.addSubview(topBarView!)
    }

    func didPresentSearchController(_ searchController: UISearchController) {}

    func willDismissSearchController(_ searchController: UISearchController) {
        topBarView?.removeFromSuperview()
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        let resultsController = searchController.searchResultsController as! TLIResultsTableViewController
        resultsController.frc?.delegate = nil
        resultsController.frc = nil
    }

    // MARK: UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {

        if searchController.searchBar.text!.length() > 0 {
            let color = findColorByName(searchController.searchBar.text!.lowercased())
            let resultsController = searchController.searchResultsController as! TLIResultsTableViewController

            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "List")
            let positionDescriptor = NSSortDescriptor(key: "position", ascending: false)
            let titleDescriptor  = NSSortDescriptor(key: "title", ascending: true)
            fetchRequest.sortDescriptors = [
                positionDescriptor,
                titleDescriptor]
            let titlePredicate = NSPredicate(
                format: "title CONTAINS[cd] %@ AND archivedAt = nil", searchController.searchBar.text!.lowercased())
            let colorPredicate = NSPredicate(format: "color CONTAINS[cd] %@ AND archivedAt = nil", color)

            let predicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [titlePredicate, colorPredicate])
            fetchRequest.predicate = predicate
            resultsController.frc = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: managedObjectContext,
                sectionNameKeyPath: nil,
                cacheName: nil)
            resultsController.frc?.delegate = self

            do {
                try resultsController.frc?.performFetch()
                resultsController.tableView?.reloadData()
                if resultsController.checkForEmptyResults() {
                }
            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }
        }
    }

    func findColorByName(_ name: String) -> String {
        switch name {
        case "purple":
            return "#6a6de2"
        case "blue":
            return "#008efe"
        case "red":
            return "#fe4565"
        case "orange":
            return "#ffa600"
        case "green":
            return "#50de72"
        case "yellow":
            return "#ffd401"
        default:
            return ""
        }
    }
}

extension TLIListsViewController {
    fileprivate func registerNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TLIListsViewController.syncActivityDidEndNotification(_:)),
            name: NSNotification.Name.IDMSyncActivityDidEnd,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TLIListsViewController.syncActivityDidBeginNotification(_:)),
            name: NSNotification.Name.IDMSyncActivityDidBegin,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TLIListsViewController.updateFonts),
            name: NSNotification.Name(
                rawValue: TLINotifications.kTLIFontDidChangeNotification as String),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TLIListsViewController.appBecomeActive),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TLIListsViewController.onChangeSize(_:)),
            name: NSNotification.Name.UIContentSizeCategoryDidChange,
            object: nil)
    }
    fileprivate func unregisterNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.IDMSyncActivityDidEnd,
            object: nil)
    }
}
