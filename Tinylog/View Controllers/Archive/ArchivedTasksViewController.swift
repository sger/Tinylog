//
//  ArchivedTasksViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

final class ArchivedTasksViewController: CoreDataTableViewController {

    private let managedObjectContext: NSManagedObjectContext
    private var currentIndexPath: IndexPath?
    private let list: TLIList

    var onTapCloseButton: (() -> Void)?

    private lazy var noTasksLabel: UILabel = {
        let noTasksLabel: UILabel = UILabel()
        noTasksLabel.font = UIFont.tinylogFontOfSize(18.0)
        noTasksLabel.textColor = UIColor.tinylogTextColor
        noTasksLabel.textAlignment = .center
        noTasksLabel.text = "No Archives"
        return noTasksLabel
    }()

    init(managedObjectContext: NSManagedObjectContext, list: TLIList) {
        self.managedObjectContext = managedObjectContext
        self.list = list
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureFetch() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Task")
        let positionDescriptor = NSSortDescriptor(key: "position", ascending: false)
        let displayLongTextDescriptor  = NSSortDescriptor(key: "displayLongText", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, displayLongTextDescriptor]
        fetchRequest.predicate  = NSPredicate(format: "list = %@ AND archivedAt != nil", list)
        fetchRequest.fetchBatchSize = 20
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

        configureFetch()

        title = "Archives"

        setupNavigationBarProperties()

        tableView?.backgroundColor = UIColor(named: "mainColor")
        tableView?.separatorColor = UIColor(named: "tableViewSeparator")
        tableView?.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView?.register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskTableViewCell")
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = GenericTableViewCell.cellHeight
        tableView?.tableFooterView = UIView()

        view.addSubview(noTasksLabel)

        noTasksLabel.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close",
                                                           style: UIBarButtonItem.Style.plain,
                                                           target: self,
                                                           action: #selector(ArchivedTasksViewController.close(_:)))

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onChangeSize(_:)),
                                               name: UIContentSizeCategory.didChangeNotification, object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.syncActivityDidEndNotification(_:)),
                                               name: NSNotification.Name.IDMSyncActivityDidEnd, object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.syncActivityDidBeginNotification(_:)),
                                               name: NSNotification.Name.IDMSyncActivityDidBegin, object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateFonts),
                                               name: NSNotification.Name(
                                                rawValue: Notifications.fontDidChangeNotification), object: nil)
    }

    @objc func updateFonts() {
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForTasks()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setEditing(false, animated: false)
    }

    // MARK: Close

    @objc func close(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    func checkForTasks() {
        if let fetchedObjects = self.frc?.fetchedObjects {
            if fetchedObjects.isEmpty {
                noTasksLabel.isHidden = false
            } else {
                noTasksLabel.isHidden = true
            }
        }
    }

    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(
            style: UITableViewRowAction.Style.default,
            title: "Delete",
            handler: {_, indexpath in
                if let task: TLITask = self.frc?.object(at: indexpath) as? TLITask {
                    self.managedObjectContext.delete(task)
                    try? self.managedObjectContext.save()
                }

                self.checkForTasks()
                self.setEditing(false, animated: true)
                self.tableView?.reloadData()
        })
        deleteRowAction.backgroundColor = UIColor.tinylogDeleteRowAction

        let restoreRowAction = UITableViewRowAction(
            style: UITableViewRowAction.Style.default,
            title: "Restore", handler: {_, indexpath in
                if let task: TLITask = self.frc?.object(at: indexpath) as? TLITask {
                    task.archivedAt = nil
                    try? self.managedObjectContext.save()
                }
                self.checkForTasks()
                self.setEditing(false, animated: true)
                self.tableView?.reloadData()
        })
        restoreRowAction.backgroundColor = UIColor.tinylogMainColor
        return [restoreRowAction, deleteRowAction]
    }

    @objc func onChangeSize(_ notification: Notification) {
        tableView?.reloadData()
    }

    override func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        guard let task: TLITask = self.frc?.object(at: indexPath) as? TLITask,
            let taskTableViewCell: TaskTableViewCell = cell as? TaskTableViewCell else {
                return
        }
        taskTableViewCell.managedObjectContext = managedObjectContext
        taskTableViewCell.task = task
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TaskTableViewCell = tableView.dequeue(for: indexPath)
        cell.selectionStyle = .none
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
}
