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

final class ListsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    weak var delegate: ListsViewControllerDelegate?

    private let managedObjectContext: NSManagedObjectContext
    // swiftlint:disable force_unwrapping
    private let reachability = ReachabilityManager.instance.reachability!
    private var isFetchedResultsControllerUpdating: Bool = false
    private var tableView: UITableView?
    private var frc: NSFetchedResultsController<TLIList>?
    private let searchController = UISearchController(searchResultsController: nil)

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

    private var noResultsLabel: UILabel = {
        let noResultsLabel: UILabel = UILabel()
        noResultsLabel.font = UIFont.tinylogFontOfSize(16.0)
        noResultsLabel.textColor = UIColor(named: "textColor")
        noResultsLabel.textAlignment = NSTextAlignment.center
        noResultsLabel.text = localizedString(key: "No_results")
        noResultsLabel.isHidden = true
        return noResultsLabel
    }()

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        tableView = UITableView(frame: .zero, style: .plain)
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureFetchRequest() {
        let fetchRequest = TLIList.sortedFetchRequest(with: TLIList.defaultPredicate)
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
        frc = NSFetchedResultsController(fetchRequest: fetchRequest,
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

    override func viewDidLoad() {
        super.viewDidLoad()

        title = localizedString(key: "My_lists")
        view.accessibilityIdentifier = "MyLists"

        configureFetchRequest()
        setupNavigationBarProperties()
        setupUITableView()
        addSearchController(with: localizedString(key: "Search"), searchResultsUpdater: self)
        setupListsFooterView()

        let settingsButton: UIButton = UIButton(type: .custom)
        settingsButton.accessibilityIdentifier = "settingsButton"
        settingsButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        settingsButton.setBackgroundImage(UIImage(named: "740-gear-toolbar"), for: .normal)
        settingsButton.setBackgroundImage(UIImage(named: "740-gear-toolbar"), for: .highlighted)
        settingsButton.addTarget(self,
                                 action: #selector(self.displaySettings(_:)),
                                 for: .touchDown)

        let settingsBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: settingsButton)
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = settingsBarButtonItem

        emptyListsLabel.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }

        noResultsLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

        setEditing(false, animated: false)

        registerNotifications()
    }

    deinit {
        unregisterNotifications()
    }

    override func loadView() {
        super.loadView()
        guard let tableView = tableView else {
            return
        }
        view.addSubview(tableView)
        view.addSubview(emptyListsLabel)
        view.addSubview(noResultsLabel)
        view.addSubview(listsFooterView)
        view.setNeedsUpdateConstraints()
    }

    private func setupUITableView() {
        tableView?.dataSource = self
        tableView?.delegate = self
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
    }

    private func setupListsFooterView() {
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
            syncManager.synchronize { _ -> Void in }
        }
    }

    @objc func updateFonts() {
        tableView?.reloadData()
    }

    @objc func syncActivityDidEndNotification(_ notification: Notification) {
        if TLISyncManager.shared().canSynchronize() {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            switch reachability.connection {
            case .wifi, .cellular:
                let dateFormatter = DateFormatter()
                dateFormatter.formatterBehavior = .behavior10_4
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                if let dateValue = dateFormatter.string(for: Date()) {
                    listsFooterView.updateInfoLabel("Last Updated \(dateValue)")
                }
            case .unavailable, .none:
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
        deselectTableViewCell(animated)

        if Environment.current.userDefaults.bool(forKey: EnvUserDefaults.syncMode) {
            startSync()
        }
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
        tableView?.setEditing(editing, animated: animated)
    }

    @objc func toggleEditMode(_ sender: UIBarButtonItem) {
        setEditing(!isEditing, animated: true)
    }

    private func deselectTableViewCell(_ animated: Bool) {
        guard let indexPathForSelectedRow = tableView?.indexPathForSelectedRow else {
            return
        }

        tableView?.deselectRow(at: indexPathForSelectedRow, animated: animated)
    }

    private func updateLists(with list: TLIList?,
                             sourceIndexPath: IndexPath,
                             destinationIndexPath: IndexPath) {
        guard let list = list else {
            return
        }

        // Fetch all lists from core data context
        var fetchedLists: [TLIList] = frc?.fetchedObjects ?? []

        // Remove selected list item from fetched lists
        fetchedLists = fetchedLists.filter { $0 != list }

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

        for (index, list) in fetchedLists.enumerated() {
            list.position = fetchedLists.count - index as NSNumber
        }
    }

    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        if sourceIndexPath.row == destinationIndexPath.row {
            return
        }

        // Disable fetched results controller

        isFetchedResultsControllerUpdating = true

        let list = frc?.object(at: sourceIndexPath)

        updateLists(with: list,
                    sourceIndexPath: sourceIndexPath,
                    destinationIndexPath: destinationIndexPath)

        try? managedObjectContext.save()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = frc?.sections?[section] else { return 0 }
        return section.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ListTableViewCell = tableView.dequeue(for: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    private func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        guard let list: TLIList = frc?.object(at: indexPath),
              let listTableViewCell: ListTableViewCell = cell as? ListTableViewCell else {
            return
        }
        listTableViewCell.list = list
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let list = frc?.object(at: indexPath) else {
            return
        }
        delegate?.listsViewControllerDidTapList(self, list: list)
    }

    func tableView(_ tableView: UITableView,
                   titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle != .delete {
            return
        }

        guard let list: TLIList = frc?.object(at: indexPath) else {
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
                rawValue: Notifications.fontDidChangeNotification),
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
            emptyListsLabel.isHidden = false
        } else {
            emptyListsLabel.isHidden = true
        }
    }
}

// MARK: - UITableViewDataSource

extension ListsViewController {

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editRowAction = UITableViewRowAction(
            style: .default,
            title: "Edit",
            handler: { [weak self] (_, indexpath) in
                guard let self = self,
                      let list: TLIList = self.frc?.object(at: indexpath) else {
                    return
                }
                self.delegate?.listsViewControllerDidAddList(self, list: list, selectedMode: .edit)
        })

        editRowAction.backgroundColor = UIColor.tinylogEditRowAction

        let archiveRowAction = UITableViewRowAction(
            style: .default,
            title: "Archive",
            handler: { [weak self] (_, indexpath) in
                guard let self = self,
                      let list: TLIList = self.frc?.object(at: indexpath) else {
                    return
                }
                list.archivedAt = Date()
                try? self.managedObjectContext.save()
                self.checkForLists()
                self.tableView?.reloadData()
        })

        archiveRowAction.backgroundColor = UIColor.tinylogMainColor
        return [archiveRowAction, editRowAction]
    }
}

// MARK: - UISearchResultsUpdating

extension ListsViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        let color = Utils.findColorByName(searchText)
        frc?.fetchRequest.predicate = TLIList.predicate(for: searchText.lowercased(), color: color)
        reloadFetchedResultsController()
    }

    private func reloadFetchedResultsController() {
        do {
            try frc?.performFetch()
            tableView?.reloadData()

            if let fetchedObjects = frc?.fetchedObjects,
               fetchedObjects.isEmpty {
                noResultsLabel.isHidden = false
            } else {
                noResultsLabel.isHidden = true
            }
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}

// MARK: - ListsFooterViewDelegate

extension ListsViewController: ListsFooterViewDelegate {

    func selectTableViewCell(with list: TLIList) {
        guard let indexPath = frc?.indexPath(forObject: list) else {
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

// MARK: - NSFetchedResultsControllerDelegate

extension ListsViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if isFetchedResultsControllerUpdating {
            return
        }
        tableView?.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        if isFetchedResultsControllerUpdating {
            return
        }

        switch type {
        case .insert:
            tableView?.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView?.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

            if isFetchedResultsControllerUpdating {
                return
            }

            switch type {
            case .insert:
                if let newIndexPath = newIndexPath {
                    tableView?.insertRows(at: [newIndexPath],
                                          with: .fade)
                }

            case .delete:
                if let indexPath = indexPath {
                    tableView?.deleteRows(at: [indexPath],
                                          with: .fade)
                }

            case .update:
                if let indexPath = indexPath,
                   let cell = tableView?.cellForRow(at: indexPath) {
                        configureCell(cell, atIndexPath: indexPath)
                }
            case .move:
                if let indexPath = indexPath,
                   let newIndexPath = newIndexPath {
                        tableView?.deleteRows(at: [indexPath],
                                              with: .fade)
                        tableView?.insertRows(at: [newIndexPath],
                                              with: .fade)
                }
            @unknown default: break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if isFetchedResultsControllerUpdating {
            isFetchedResultsControllerUpdating = false
        } else {
            tableView?.endUpdates()
        }
    }
}
