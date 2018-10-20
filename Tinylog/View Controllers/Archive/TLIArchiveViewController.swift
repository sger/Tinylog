//
//  TLIArchiveViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import CoreData
import Reachability
// swiftlint:disable force_unwrapping
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

class TLIArchiveViewController: TLICoreDataTableViewController,
    UITextFieldDelegate, TLIAddListViewControllerDelegate,
    UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

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
    var managedObjectContext: NSManagedObjectContext!
    var editingIndexPath: IndexPath?
    var estimatedRowHeightCache: NSMutableDictionary?
    var resultsTableViewController: TLIResultsTableViewController?
    var searchController: UISearchController?
    var topBarView: UIView?

    func configureFetch() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "List")
        let positionDescriptor = NSSortDescriptor(key: "position", ascending: false)
        let titleDescriptor  = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, titleDescriptor]
        fetchRequest.predicate = NSPredicate(format: "archivedAt != nil")
        self.frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        self.frc?.delegate = self

        do {
             try self.frc?.performFetch()
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    lazy var noListsLabel: UILabel? = {
        let noTasksLabel: UILabel = UILabel()
        noTasksLabel.font = UIFont.tinylogFontOfSize(16.0)
        noTasksLabel.textColor = UIColor.tinylogTextColor
        noTasksLabel.textAlignment = NSTextAlignment.center
        noTasksLabel.text = "No Archives"
        noTasksLabel.frame = CGRect(
            x: self.view.frame.size.width / 2.0 - self.view.frame.size.width / 2.0,
            y: self.view.frame.size.height / 2.0 - 44.0 / 2.0,
            width: self.view.frame.size.width,
            height: 44.0)
        return noTasksLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureFetch()

        self.title = "My Archives"

        self.view.backgroundColor = UIColor.tinylogLightGray
        self.tableView?.backgroundColor = UIColor.tinylogLightGray
        self.tableView?.backgroundView = UIView()
        self.tableView?.backgroundView?.backgroundColor = UIColor.clear
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView?.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height)

        self.tableView?.register(TLIListTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        self.tableView?.rowHeight = UITableView.automaticDimension
        self.tableView?.estimatedRowHeight = 61

        resultsTableViewController = TLIResultsTableViewController()
        resultsTableViewController?.tableView?.delegate = self
        searchController = UISearchController(searchResultsController: resultsTableViewController)
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.sizeToFit()
        searchController?.searchBar.backgroundColor = UIColor.tinylogLightGray
        searchController?.searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchController?.searchBar.setSearchFieldBackgroundImage(
            UIImage(named: "search-bar-bg-gray"), for: UIControl.State())

        searchController?.searchBar.tintColor = UIColor.tinylogMainColor

        if let searchField: UITextField = searchController?.searchBar.value(
            forKey: "searchField") as? UITextField {
            searchField.textColor = UIColor.tinylogTextColor
        }

        self.tableView?.tableHeaderView = searchController?.searchBar
        searchController?.delegate = self
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.searchBar.delegate = self

        self.view.addSubview(self.noListsLabel!)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(TLIArchiveViewController.close(_:)))

        setEditing(false, animated: false)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TLIArchiveViewController.syncActivityDidEndNotification(_:)),
            name: NSNotification.Name.IDMSyncActivityDidEnd,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TLIArchiveViewController.syncActivityDidBeginNotification(_:)),
            name: NSNotification.Name.IDMSyncActivityDidBegin,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TLIArchiveViewController.updateFonts),
            name: NSNotification.Name(
                rawValue: TLINotifications.kTLIFontDidChangeNotification as String as String),
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TLIArchiveViewController.appBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TLIArchiveViewController.onChangeSize(_:)),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil)

        definesPresentationContext = true

    }

    @objc func onChangeSize(_ notification: Notification) {
        self.tableView?.reloadData()
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
        }

        self.tableView?.reloadData()
    }

    @objc func syncActivityDidBeginNotification(_ notification: Notification) {
        if TLISyncManager.shared().canSynchronize() {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }

    // MARK: Close
    @objc func close(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    // swiftlint:disable force_unwrapping
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.noListsLabel!.frame = CGRect(
            x: self.view.frame.size.width / 2.0 - self.view.frame.size.width / 2.0,
            y: self.view.frame.size.height / 2.0 - 44.0 / 2.0,
            width: self.view.frame.size.width,
            height: 44.0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForLists()
        if tableView!.indexPathForSelectedRow != nil {
            tableView?.deselectRow(at: tableView!.indexPathForSelectedRow!, animated: animated)
        }
        initEstimatedRowHeightCacheIfNeeded()
    }

    func checkForLists() {

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "List")
        let positionDescriptor = NSSortDescriptor(key: "position", ascending: false)
        let titleDescriptor  = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, titleDescriptor]
        fetchRequest.predicate = NSPredicate(format: "archivedAt != nil")

        do {
            let results = try managedObjectContext.fetch(fetchRequest)

            if results.isEmpty {
                self.noListsLabel?.isHidden = false
            } else {
                self.noListsLabel?.isHidden = true
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    // MARK: UITableViewDataSource

    func tableView(
        _ tableView: UITableView,
        editActionsForRowAtIndexPath indexPath: IndexPath) -> [AnyObject]? {

        let deleteRowAction = UITableViewRowAction(
            style: UITableViewRowAction.Style.default,
            title: "Delete", handler: {_, indexpath in
            if let list: TLIList = self.frc?.object(at: indexpath) as? TLIList {
                self.managedObjectContext.delete(list)
                // swiftlint:disable force_try
                try! self.managedObjectContext.save()
                self.checkForLists()
            }
        })
        deleteRowAction.backgroundColor = UIColor(
            red: 254.0 / 255.0,
            green: 69.0 / 255.0,
            blue: 101.0 / 255.0,
            alpha: 1.0)

        let restoreRowAction = UITableViewRowAction(
            style: UITableViewRowAction.Style.default,
            title: "Restore",
            handler: {_, indexpath in
                if let list: TLIList = self.frc?.object(at: indexpath) as? TLIList {
                    list.archivedAt = nil
                    try! self.managedObjectContext.save()
                    self.checkForLists()
                }
        })
        restoreRowAction.backgroundColor = UIColor.tinylogMainColor
        return [restoreRowAction, deleteRowAction]
    }

    func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }

    func listAtIndexPath(_ indexPath: IndexPath) -> TLIList? {
        if let list = self.frc?.object(at: indexPath) as? TLIList {
            return list
        }
        return nil
    }

    // swiftlint:disable force_unwrapping
    // swiftlint:disable force_cast
    func updateList(_ list: TLIList, sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        var fetchedLists: [AnyObject] = (self.frc?.fetchedObjects)!

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

    func tableView(
        _ tableView: UITableView,
        moveRowAtIndexPath sourceIndexPath: IndexPath,
        toIndexPath destinationIndexPath: IndexPath) {
        if sourceIndexPath.row == destinationIndexPath.row {
            return
        }

        //Disable fetched results controller
        self.ignoreNextUpdates = true

        let list = self.listAtIndexPath(sourceIndexPath)!

        updateList(list, sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)

        try! managedObjectContext.save()
    }

    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
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

    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        var list: TLIList

        if tableView == self.tableView {
            list = self.frc?.object(at: indexPath) as! TLIList
        } else {
            list = resultsTableViewController?.frc?.object(at: indexPath) as! TLIList
        }

        let IS_IPAD = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)

        // swiftlint:disable line_length
        if  IS_IPAD {
            TLISplitViewController.sharedSplitViewController().listViewController?.managedObject = list
            TLISplitViewController.sharedSplitViewController().listViewController?.enableDidSelectRowAtIndexPath = false
        } else {
            let tasksViewController: TLITasksViewController = TLITasksViewController()
            tasksViewController.managedObjectContext = managedObjectContext
            tasksViewController.enableDidSelectRowAtIndexPath = false
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

    func onClose(_ addListViewController: TLIAddListViewController, list: TLIList) {
        let indexPath = self.frc?.indexPath(forObject: list)
        self.tableView?.selectRow(at: indexPath!, animated: true, scrollPosition: UITableView.ScrollPosition.none)
        let tasksViewController: TLITasksViewController = TLITasksViewController()
        tasksViewController.managedObjectContext = managedObjectContext
        tasksViewController.list = list
        tasksViewController.focusTextField = true
        self.navigationController?.pushViewController(tasksViewController, animated: true)
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
            fetchRequest.sortDescriptors = [positionDescriptor, titleDescriptor]
            let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@ AND archivedAt != nil", searchController.searchBar.text!.lowercased())
            let colorPredicate = NSPredicate(format: "color CONTAINS[cd] %@ AND archivedAt != nil", color)
            let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, colorPredicate])
            fetchRequest.predicate = predicate
            resultsController.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
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
