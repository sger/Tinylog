//
//  ArchivedListsViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import CoreData
import Reachability

protocol ArchivedListsViewControllerDelegate: AnyObject {
    func archivedListsViewControllerDidTapButton()
}

class ArchivedListsViewController: CoreDataTableViewController,
    UITextFieldDelegate,
    UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    fileprivate let managedObjectContext: NSManagedObjectContext
    var resultsTableViewController: ResultsViewController?
    weak var delegate: ArchivedListsViewControllerDelegate?

    func configureFetch() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "List")
        let positionDescriptor = NSSortDescriptor(key: "position", ascending: false)
        let titleDescriptor  = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, titleDescriptor]
        fetchRequest.predicate = NSPredicate(format: "archivedAt != nil")
        frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        frc?.delegate = self

        do {
             try frc?.performFetch()
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    lazy var emptyArchivesLabel: UILabel = {
        let noArchivesLabel = UILabel()
        noArchivesLabel.font = UIFont.tinylogFontOfSize(18.0)
        noArchivesLabel.textColor = UIColor.tinylogTextColor
        noArchivesLabel.textAlignment = NSTextAlignment.center
        noArchivesLabel.text = "No Archives"
        return noArchivesLabel
    }()

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // swiftlint:disable force_unwrapping
    override func viewDidLoad() {
        super.viewDidLoad()

        configureFetch()

        title = localizedString(key: "My_archives")
        view.accessibilityIdentifier = "MyArchives"

        setupNavigationBarProperties()

        tableView?.backgroundColor = UIColor(named: "mainColor")
        tableView?.backgroundView = UIView()
        tableView?.backgroundView?.backgroundColor = UIColor.clear
        tableView?.separatorColor = UIColor(named: "tableViewSeparator")
        tableView?.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView?.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.cellIdentifier)
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 60
        tableView?.tableFooterView = UIView()
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        tableView?.allowsSelection = false

        tableView?.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(view)
            make.right.equalTo(view)
        })

        resultsTableViewController = ResultsViewController()

        addSearchController(with: "Search",
                            searchResultsUpdater: self,
                            searchResultsController: resultsTableViewController!)

        view.addSubview(emptyArchivesLabel)

        emptyArchivesLabel.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(self.close(_:)))

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ArchivedListsViewController.syncActivityDidEndNotification(_:)),
            name: NSNotification.Name.IDMSyncActivityDidEnd,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ArchivedListsViewController.syncActivityDidBeginNotification(_:)),
            name: NSNotification.Name.IDMSyncActivityDidBegin,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ArchivedListsViewController.updateFonts),
            name: NSNotification.Name(
                rawValue: Notifications.fontDidChangeNotification),
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ArchivedListsViewController.appBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ArchivedListsViewController.onChangeSize(_:)),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil)
    }

    @objc func onChangeSize(_ notification: Notification) {
        tableView?.reloadData()
    }

    @objc func appBecomeActive() {
        startSync()
    }

    func startSync() {
        let syncManager: TLISyncManager = TLISyncManager.shared()
        if syncManager.canSynchronize() {
            syncManager.synchronize { (_) -> Void in }
        }
    }

    @objc func updateFonts() {
        tableView?.reloadData()
    }

    @objc func syncActivityDidEndNotification(_ notification: Notification) {
        if TLISyncManager.shared().canSynchronize() {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }

        tableView?.reloadData()
    }

    @objc func syncActivityDidBeginNotification(_ notification: Notification) {
        if TLISyncManager.shared().canSynchronize() {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }

    // MARK: - Close

    @objc func close(_ button: UIButton) {
        delegate?.archivedListsViewControllerDidTapButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForLists()
        if tableView!.indexPathForSelectedRow != nil {
            tableView?.deselectRow(at: tableView!.indexPathForSelectedRow!, animated: animated)
        }
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
                emptyArchivesLabel.isHidden = false
            } else {
                emptyArchivesLabel.isHidden = true
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(
            style: UITableViewRowAction.Style.default,
            title: "Delete", handler: {_, indexpath in
                if let list: TLIList = self.frc?.object(at: indexpath) as? TLIList {
                    self.managedObjectContext.delete(list)
                    // swiftlint:disable force_try
                    try! self.managedObjectContext.save()
                    self.tableView?.reloadData()
                    self.checkForLists()
                }
        })
        deleteRowAction.backgroundColor = UIColor.tinylogDeleteRowAction

        let restoreRowAction = UITableViewRowAction(
            style: UITableViewRowAction.Style.default,
            title: "Restore",
            handler: {_, indexpath in
                if let list: TLIList = self.frc?.object(at: indexpath) as? TLIList {
                    list.archivedAt = nil
                    try! self.managedObjectContext.save()
                    self.tableView?.reloadData()
                    self.checkForLists()
                }
        })
        restoreRowAction.backgroundColor = UIColor.tinylogMainColor
        return [restoreRowAction, deleteRowAction]
    }

    func listAtIndexPath(_ indexPath: IndexPath) -> TLIList? {
        if let list = frc?.object(at: indexPath) as? TLIList {
            return list
        }
        return nil
    }

    // swiftlint:disable force_unwrapping
    // swiftlint:disable force_cast
    func updateList(_ list: TLIList, sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        var fetchedLists: [AnyObject] = (frc?.fetchedObjects)!

        // Remove current list item
        fetchedLists = fetchedLists.filter { $0 as! TLIList != list }

        var sortedIndex = destinationIndexPath.row

        for sectionIndex in 0..<destinationIndexPath.section {
            sortedIndex += (frc?.sections?[sectionIndex].numberOfObjects)!

            if sectionIndex == sourceIndexPath.section {
                sortedIndex -= 1
            }
        }

        fetchedLists.insert(list, at: sortedIndex)

        for(index, list) in fetchedLists.enumerated() {
            let tmpList = list as! TLIList
            tmpList.position = fetchedLists.count - index as NSNumber
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(
        _ tableView: UITableView,
        moveRowAtIndexPath sourceIndexPath: IndexPath,
        toIndexPath destinationIndexPath: IndexPath) {
        if sourceIndexPath.row == destinationIndexPath.row {
            return
        }

        // Disable fetched results controller
        ignoreNextUpdates = true

        let list = listAtIndexPath(sourceIndexPath)!

        updateList(list,
                   sourceIndexPath: sourceIndexPath,
                   destinationIndexPath: destinationIndexPath)

        try! managedObjectContext.save()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ListTableViewCell = tableView.dequeue(for: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let list: TLIList = frc?.object(at: indexPath) as! TLIList
        let listTableViewCell: ListTableViewCell = cell as! ListTableViewCell
        listTableViewCell.list = list
    }

    func tableView(_ tableView: UITableView,
                   titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: IndexPath) -> String! {
        return "Delete"
    }

    func tableView(_ tableView: UITableView,
                   commitEditingStyle editingStyle: UITableViewCell.EditingStyle,
                   forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle != UITableViewCell.EditingStyle.delete {
            return
        }

        let list: TLIList = frc?.object(at: indexPath) as! TLIList

        managedObjectContext.delete(list)
        try! managedObjectContext.save()
    }

    func performBackgroundUpdates(_ completionHandler: ((UIBackgroundFetchResult) -> Void)!) {
        completionHandler(UIBackgroundFetchResult.newData)
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

    // MARK: - UISearchControllerDelegate

    func presentSearchController(_ searchController: UISearchController) {}

    func willPresentSearchController(_ searchController: UISearchController) {}

    func didPresentSearchController(_ searchController: UISearchController) {}

    func willDismissSearchController(_ searchController: UISearchController) {}

    func didDismissSearchController(_ searchController: UISearchController) {
        let resultsController = searchController.searchResultsController as! ResultsViewController
        resultsController.frc?.delegate = nil
        resultsController.frc = nil
    }

    // MARK: UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {

        if let text = searchController.searchBar.text {
            if !text.isEmpty {
                let lowercasedText = text.lowercased()
                let color = Utils.findColorByName(lowercasedText)
                let fetchRequest = TLIList.filterArchivedLists(with: text, color: color)
                let resultsController = searchController.searchResultsController as! ResultsViewController
                resultsController.frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: managedObjectContext,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: nil)
                resultsController.frc?.delegate = self

                do {
                    try resultsController.frc?.performFetch()
                    resultsController.tableView?.reloadData()
                    resultsController.showNoResults()
                } catch let error as NSError {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
}
