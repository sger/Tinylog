//
//  ListsViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import CoreData
import SnapKit

protocol ListsViewControllerDelegate: AnyObject {
    func listsViewControllerDidTapList(_ viewController: ListsViewController, list: TLIList)
    func listsViewControllerDidTapSettings(_ viewController: ListsViewController)
    func listsViewControllerDidAddList(_ viewController: ListsViewController,
                                       list: TLIList?,
                                       selectedMode mode: AddListViewController.Mode)

    func listsViewControllerDidTapArchives(_ viewController: ListsViewController)
}

final class ListsViewController: CoreDataTableViewController {

    weak var delegate: ListsViewControllerDelegate?

    private let managedObjectContext: NSManagedObjectContext
    // swiftlint:disable force_unwrapping
    private let reachability = ReachabilityManager.instance.reachability!
    private var resultsViewController: ResultsViewController?

    private var listsFooterView: ListsFooterView = {
        let listsFooterView = ListsFooterView()
        return listsFooterView
    }()

    private var emptyListsLabel: UILabel = {
        let noListsLabel: UILabel = UILabel()
        noListsLabel.font = UIFont.tinylogFontOfSize(18.0)
        noListsLabel.textColor = UIColor.tinylogTextColor
        noListsLabel.textAlignment = NSTextAlignment.center
        noListsLabel.text = localizedString(key: "Empty_lists")
        return noListsLabel
    }()

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

        title = localizedString(key: "My_lists")
        view.accessibilityIdentifier = "MyLists"

        setupNavigationBarProperties()

        tableView?.backgroundColor = UIColor(named: "mainColor")
        tableView?.backgroundView = UIView()
        tableView?.backgroundView?.backgroundColor = UIColor.clear
        tableView?.separatorColor = UIColor(named: "tableViewSeparator")
        tableView?.separatorInset = UIEdgeInsets(top: 0, left: 22.0, bottom: 0, right: 0)
        tableView?.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.cellIdentifier)
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 60
        tableView?.tableFooterView = UIView()
        tableView?.translatesAutoresizingMaskIntoConstraints = false

        tableView?.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-listsFooterView.footerHeight)
            make.left.equalTo(view)
            make.right.equalTo(view)
        })

        resultsViewController = ResultsViewController()

        addSearchController(with: "Search",
                            searchResultsUpdater: self,
                            searchResultsController: resultsViewController)

        resultsViewController?.tableView?.delegate = self

        let settingsButton: UIButton = UIButton(type: .custom)
        settingsButton.accessibilityIdentifier = "settingsButton"
        settingsButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        settingsButton.setBackgroundImage(UIImage(named: "740-gear-toolbar"), for: .selected)
        settingsButton.setBackgroundImage(UIImage(named: "740-gear-toolbar"), for: .highlighted)
        settingsButton.addTarget(self,
                                 action: #selector(self.displaySettings(_:)),
                                 for: .touchDown)

        let settingsBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: settingsButton)
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = settingsBarButtonItem

        listsFooterView.delegate = self
        listsFooterView.snp.makeConstraints { (make) in
            make.left.equalTo(view)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.width.equalTo(view)
            make.height.equalTo(listsFooterView.footerHeight)
        }

        emptyListsLabel.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }

        setEditing(false, animated: false)

        registerNotifications()
    }

    deinit {
        unregisterNotifications()
    }

    override func loadView() {
        super.loadView()
        view.addSubview(emptyListsLabel)
        view.addSubview(listsFooterView)
        view.setNeedsUpdateConstraints()
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

            let dateFormatter = DateFormatter()
            dateFormatter.formatterBehavior = DateFormatter.Behavior.behavior10_4
            dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.timeStyle = DateFormatter.Style.short

            if reachability.connection == .wifi || reachability.connection == .cellular {
                listsFooterView.updateInfoLabel("Last Updated \(dateFormatter.string(from: Date()))")
            } else if reachability.connection == .unavailable {
                listsFooterView.updateInfoLabel("Offline")
            }

            checkForLists()

            tableView?.reloadData()
        }
    }

    @objc func syncActivityDidBeginNotification(_ notification: Notification) {
        if TLISyncManager.shared().canSynchronize() {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true

            if reachability.connection == .unavailable {
                listsFooterView.updateInfoLabel("Offline")
            } else {
                listsFooterView.updateInfoLabel("Syncing...")
            }
        }
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

    // MARK: - Display Setup

    func displaySetup() {
        let setupViewController: SetupViewController = SetupViewController()
        let nc: UINavigationController = UINavigationController(rootViewController: setupViewController)
        nc.modalPresentationStyle = .formSheet
        navigationController?.present(nc, animated: true, completion: nil)
    }

    // MARK: Display Settings

    @objc func displaySettings(_ sender: UIButton) {
        delegate?.listsViewControllerDidTapSettings(self)
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

        if Environment.current.userDefaults.bool(forKey: EnvUserDefaults.syncMode) {
            startSync()
        }

        guard let indexPath = tableView?.indexPathForSelectedRow else {
            return
        }

        tableView?.deselectRow(at: indexPath, animated: animated)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                                style: UIBarButtonItem.Style.plain,
                                                                target: self,
                                                                action: #selector(ListsViewController.toggleEditMode(_:)))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit",
                                                                style: UIBarButtonItem.Style.plain,
                                                                target: self,
                                                                action: #selector(ListsViewController.toggleEditMode(_:)))
        }
    }

    @objc func toggleEditMode(_ sender: UIBarButtonItem) {
        setEditing(!isEditing, animated: true)
    }

    func listAtIndexPath(_ indexPath: IndexPath) -> TLIList? {
        guard let list = frc?.object(at: indexPath) as? TLIList else {
            return nil
        }
        return list
    }

    func updateList(_ list: TLIList, sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        guard let fetchedObjects = frc?.fetchedObjects else {
            return
        }
        var fetchedLists: [AnyObject] = fetchedObjects

        // Remove current list item
        fetchedLists = fetchedLists.filter { $0 as? TLIList != list }

        var sortedIndex = destinationIndexPath.row

        for sectionIndex in 0..<destinationIndexPath.section {
            guard let numberOfObjects = frc?.sections?[sectionIndex].numberOfObjects else {
                return
            }
            sortedIndex += numberOfObjects

            if sectionIndex == sourceIndexPath.section {
                sortedIndex -= 1
            }
        }

        fetchedLists.insert(list, at: sortedIndex)

        for(index, list) in fetchedLists.enumerated() {
            guard let tmpList = list as? TLIList else {
                return
            }
            tmpList.position = fetchedLists.count - index as NSNumber
        }
    }

    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        if sourceIndexPath.row == destinationIndexPath.row {
            return
        }

        // Disable fetched results controller

        ignoreNextUpdates = true

        guard let list = listAtIndexPath(sourceIndexPath) else {
            return
        }

        updateList(list,
                   sourceIndexPath: sourceIndexPath,
                   destinationIndexPath: destinationIndexPath)

        try? managedObjectContext.save()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ListTableViewCell = tableView.dequeue(for: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        if let list: TLIList = frc?.object(at: indexPath) as? TLIList,
            let listTableViewCell: ListTableViewCell = cell as? ListTableViewCell {
            listTableViewCell.list = list
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var fetchedList: TLIList?

        if tableView == self.tableView {
            fetchedList = frc?.object(at: indexPath) as? TLIList
        } else {
            fetchedList = resultsViewController?.frc?.object(at: indexPath) as? TLIList
        }

        guard let list = fetchedList else {
            return
        }

        delegate?.listsViewControllerDidTapList(self, list: list)
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

        guard let list: TLIList = frc?.object(at: indexPath) as? TLIList else {
            return
        }

        managedObjectContext.delete(list)

        try? managedObjectContext.save()
    }

    func performBackgroundUpdates(_ completionHandler: ((UIBackgroundFetchResult) -> Void)!) {
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension ListsViewController {

    private func registerNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.syncActivityDidEndNotification(_:)),
            name: NSNotification.Name.IDMSyncActivityDidEnd,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.syncActivityDidBeginNotification(_:)),
            name: NSNotification.Name.IDMSyncActivityDidBegin,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateFonts),
            name: NSNotification.Name(
                rawValue: Notifications.fontDidChangeNotification),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.appBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onChangeSize(_:)),
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
            emptyListsLabel.isHidden = false
        } else {
            emptyListsLabel.isHidden = true
        }
    }
}

// MARK: - UITableViewDataSource

extension ListsViewController {

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let editRowAction = UITableViewRowAction(
            style: .default,
            title: "Edit", handler: { _, indexpath in
                guard let list: TLIList = self.frc?.object(at: indexpath) as? TLIList else {
                    return
                }
                self.delegate?.listsViewControllerDidAddList(self, list: list, selectedMode: .edit)
        })

        editRowAction.backgroundColor = UIColor.tinylogEditRowAction

        let archiveRowAction = UITableViewRowAction(
            style: .default,
            title: "Archive",
            handler: {_, indexpath in
                guard let list: TLIList = self.frc?.object(at: indexpath) as? TLIList else {
                    return
                }
                list.archivedAt = Date()
                try? self.managedObjectContext.save()
                self.checkForLists()
                self.tableView?.reloadData()
                self.setEditing(!self.isEditing, animated: true)
        })

        archiveRowAction.backgroundColor = UIColor.tinylogMainColor
        return [archiveRowAction, editRowAction]
    }
}

extension ListsViewController: UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {

    // MARK: UISearchBarDelegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        resultsViewController?.frc?.delegate = nil
        resultsViewController?.frc = nil
    }

    // MARK: - UISearchControllerDelegate

    func didDismissSearchController(_ searchController: UISearchController) {
        let resultsController = searchController.searchResultsController as? ResultsViewController
        resultsController?.frc?.delegate = nil
        resultsController?.frc = nil
    }

    // MARK: UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            if !text.isEmpty {
                let lowercasedText = text.lowercased()
                let color = Utils.findColorByName(lowercasedText)
                let resultsController = searchController.searchResultsController as? ResultsViewController
                let fetchRequest = TLIList.filterLists(with: lowercasedText, color: color)

                resultsController?.frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: managedObjectContext,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: nil)
                resultsController?.frc?.delegate = self

                do {
                    try resultsController?.frc?.performFetch()
                    resultsController?.tableView?.reloadData()
                    resultsController?.showNoResults()
                } catch let error as NSError {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - ListsFooterViewDelegate

extension ListsViewController: ListsFooterViewDelegate {

    func selectTableViewCell(with list: TLIList) {
        guard let indexPath = frc?.indexPath(forObject: list) else {
            print("error with index path")
            return
        }

        tableView?.selectRow(at: indexPath, animated: true, scrollPosition: .none)

        checkForLists()
    }

    func listsFooterViewAddNewList(_ listsFooterView: ListsFooterView) {
        delegate?.listsViewControllerDidAddList(self, list: nil, selectedMode: .create)
    }

    func listsFooterViewDisplayArchives(_ listsFooterView: ListsFooterView) {
        delegate?.listsViewControllerDidTapArchives(self)
    }
}
