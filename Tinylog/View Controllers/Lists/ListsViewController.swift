//
//  ListsViewController.swift
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

class ListsViewController: TLICoreDataTableViewController,
    UITextFieldDelegate,
    TLIAddListViewControllerDelegate,
    UISearchControllerDelegate,
    UISearchBarDelegate,
    UISearchResultsUpdating {

    var managedObjectContext: NSManagedObjectContext!

    let kEstimateRowHeight = 61
    let kCellIdentifier = "CellIdentifier"
    var editingIndexPath: IndexPath?
    var estimatedRowHeightCache: NSMutableDictionary?
    var resultsTableViewController: ResultsTableViewController?
    var didSetupContraints = false

    var listsFooterView: ListsFooterView? = {
        let listsFooterView = ListsFooterView.newAutoLayout()
        return listsFooterView
    }()

    lazy var emptyListsLabel: UILabel? = {
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

        self.title = localizedString(key: "My_Lists")

        self.view.backgroundColor = UIColor.tinylogLightGray
        self.tableView?.backgroundColor = UIColor.tinylogLightGray
        self.tableView?.backgroundView = UIView()
        self.tableView?.backgroundView?.backgroundColor = UIColor.clear
        self.tableView?.separatorColor = UIColor(named: "tableViewSeparator")
        self.tableView?.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        self.tableView?.register(TLIListTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        self.tableView?.rowHeight = UITableView.automaticDimension
        self.tableView?.estimatedRowHeight = 61
        self.tableView?.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height - 50.0)
        self.tableView?.tableFooterView = UIView()

        resultsTableViewController = ResultsTableViewController()

        addSearchController(with: "Search", searchResultsUpdater: self, searchResultsController: resultsTableViewController!)

        let settingsImage: UIImage = UIImage(named: "740-gear-toolbar")!
        let settingsButton: UIButton = UIButton(type: UIButton.ButtonType.custom)
        settingsButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        settingsButton.setBackgroundImage(settingsImage, for: UIControl.State())
        settingsButton.setBackgroundImage(settingsImage, for: UIControl.State.highlighted)
        settingsButton.addTarget(
            self,
            action: #selector(ListsViewController.displaySettings(_:)),
            for: UIControl.Event.touchDown)

        let settingsBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: settingsButton)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = settingsBarButtonItem

        listsFooterView?.addListButton.addTarget(
            self,
            action: #selector(ListsViewController.addNewList(_:)),
            for: UIControl.Event.touchDown)
        listsFooterView?.archiveButton.addTarget(
            self,
            action: #selector(ListsViewController.displayArchive(_:)),
            for: UIControl.Event.touchDown)

        setEditing(false, animated: false)

        registerNotifications()
    }
    deinit {
        unregisterNotifications()
    }

    override func loadView() {
        super.loadView()
        view.addSubview(emptyListsLabel!)
        view.addSubview(listsFooterView!)
        view.setNeedsUpdateConstraints()
    }

    @objc func onChangeSize(_ notification: Notification) {
        self.tableView?.reloadData()
    }

    override func updateViewConstraints() {

        if !didSetupContraints {

            emptyListsLabel?.autoCenterInSuperview()

            listsFooterView?.autoMatch(.width, to: .width, of: self.view)
            listsFooterView?.autoSetDimension(.height, toSize: listsFooterView!.footHeight + self.view.safeAreaInsets.bottom)
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
        let addListViewController: AddListViewController = AddListViewController()
        addListViewController.managedObjectContext = managedObjectContext
        addListViewController.delegate = self
        addListViewController.mode = .create
        let nc: UINavigationController = UINavigationController(rootViewController: addListViewController)
        nc.modalPresentationStyle = UIModalPresentationStyle.formSheet
        self.navigationController?.present(nc, animated: true, completion: nil)
    }

    // MARK: Display Setup
    func displaySetup() {
        let setupViewController: SetupViewController = SetupViewController()
        let nc: UINavigationController = UINavigationController(rootViewController: setupViewController)
        nc.modalPresentationStyle = UIModalPresentationStyle.formSheet
        self.navigationController?.present(nc, animated: true, completion: nil)
    }

    @objc func displayArchive(_ button: TLIArchiveButton) {
        let archiveViewController: TLIArchiveViewController = TLIArchiveViewController()
        archiveViewController.managedObjectContext = managedObjectContext
        let nc: UINavigationController = UINavigationController(rootViewController: archiveViewController)
        nc.modalPresentationStyle = UIModalPresentationStyle.formSheet
        self.navigationController?.present(nc, animated: true, completion: nil)
    }

    // MARK: Display Settings

    @objc func displaySettings(_ sender: UIButton) {
        let settingsViewController: TLISettingsTableViewController = TLISettingsTableViewController()
        let nc: UINavigationController = UINavigationController(rootViewController: settingsViewController)
        nc.modalPresentationStyle = UIModalPresentationStyle.formSheet
        self.navigationController?.present(nc, animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setEditing(false, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        checkForLists()

        let userDefaults = Environment.current.userDefaults

        if userDefaults.bool(forKey: TLIUserDefaults.kSetupScreen) {
            Utils.delay(0.1, closure: { () -> Void in
                self.displaySetup()
            })
        } else {
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
                style: UIBarButtonItem.Style.plain,
                target: self,
                action: #selector(ListsViewController.toggleEditMode(_:)))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Edit",
                style: UIBarButtonItem.Style.plain,
                target: self,
                action: #selector(ListsViewController.toggleEditMode(_:)))
        }
    }

    @objc func toggleEditMode(_ sender: UIBarButtonItem) {
        setEditing(!isEditing, animated: true)
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editRowAction = UITableViewRowAction(
            style: UITableViewRowAction.Style.default,
            title: "Edit", handler: {_, indexpath in

                let list: TLIList = self.frc?.object(at: indexpath) as! TLIList

                let addListViewController: AddListViewController = AddListViewController()
                addListViewController.managedObjectContext = self.managedObjectContext
                addListViewController.delegate = self
                addListViewController.list = list
                addListViewController.mode = .edit
                let nc: UINavigationController = UINavigationController(
                    rootViewController: addListViewController)
                nc.modalPresentationStyle = UIModalPresentationStyle.formSheet
                self.navigationController?.present(nc, animated: true, completion: nil)
        })
        editRowAction.backgroundColor = UIColor.tinylogEditRowAction
        let archiveRowAction = UITableViewRowAction(
            style: UITableViewRowAction.Style.default,
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
        let list = self.frc?.object(at: indexPath) as! TLIList?
        return list
    }

    func updateList(_ list: TLIList, sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        var fetchedLists: [AnyObject] = (self.frc?.fetchedObjects as [AnyObject]?)!

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

    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCell.EditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle != UITableViewCell.EditingStyle.delete {
            return
        }

        let list: TLIList = self.frc?.object(at: indexPath) as! TLIList

        managedObjectContext.delete(list)

        try! managedObjectContext.save()
    }

    func performBackgroundUpdates(_ completionHandler: ((UIBackgroundFetchResult) -> Void)!) {
        completionHandler(UIBackgroundFetchResult.newData)
    }

    func onClose(_ addListViewController: AddListViewController, list: TLIList) {

        let indexPath = self.frc?.indexPath(forObject: list)
        self.tableView?.selectRow(at: indexPath!, animated: true, scrollPosition: UITableView.ScrollPosition.none)

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

    func willPresentSearchController(_ searchController: UISearchController) {}

    func didPresentSearchController(_ searchController: UISearchController) {}

    func willDismissSearchController(_ searchController: UISearchController) {}

    func didDismissSearchController(_ searchController: UISearchController) {
        let resultsController = searchController.searchResultsController as! ResultsTableViewController
        resultsController.frc?.delegate = nil
        resultsController.frc = nil
    }

    // MARK: UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {

        if let text = searchController.searchBar.text {
            if !text.isEmpty {
                let lowercasedText = text.lowercased()
                let color = Utils.findColorByName(lowercasedText)
                let resultsController = searchController.searchResultsController as! ResultsTableViewController
                let fetchRequest = TLIList.filter(with: lowercasedText, color: color)

                resultsController.frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: managedObjectContext,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: nil)
                resultsController.frc?.delegate = self

                do {
                    try resultsController.frc?.performFetch()
                    resultsController.tableView?.reloadData()
                    if resultsController.checkForEmptyResults() {
                        print("no results")
                    }
                } catch let error as NSError {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
}

extension ListsViewController {

    private func registerNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ListsViewController.syncActivityDidEndNotification(_:)),
            name: NSNotification.Name.IDMSyncActivityDidEnd,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ListsViewController.syncActivityDidBeginNotification(_:)),
            name: NSNotification.Name.IDMSyncActivityDidBegin,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ListsViewController.updateFonts),
            name: NSNotification.Name(
                rawValue: TLINotifications.kTLIFontDidChangeNotification),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ListsViewController.appBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ListsViewController.onChangeSize(_:)),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil)
    }

    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.IDMSyncActivityDidEnd,
            object: nil)
    }

    private func checkForLists() {
        let results = TLIList.lists(with: managedObjectContext)

        if results.isEmpty {
            self.emptyListsLabel?.isHidden = false
        } else {
            self.emptyListsLabel?.isHidden = true
        }
    }
}
