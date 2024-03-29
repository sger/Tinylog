//
//  ArchivedTasksViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_cast
import UIKit
import Nantes

final class ArchivedTasksViewController: CoreDataTableViewController, EditTaskViewControllerDelegate {

    var onTapCloseButton: (() -> Void)?
    let kCellIdentifier = "CellIdentifier"
    let kReminderCellIdentifier = "ReminderCellIdentifier"
    var managedObjectContext: NSManagedObjectContext!
    var list: TLIList?
    var offscreenCells: NSMutableDictionary?
    var estimatedRowHeightCache: NSMutableDictionary?
    var currentIndexPath: IndexPath?
    var focusTextField: Bool?
    var tasksFooterView: TasksFooterView?
    var orientation: String = "portrait"

    lazy var noTasksLabel: UILabel? = {
        let noTasksLabel: UILabel = UILabel()
        noTasksLabel.font = UIFont.tinylogFontOfSize(18.0)
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

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    // swiftlint:disable force_unwrapping
    var managedObject: TLIList? {
        willSet {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Task")
            let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
            let displayLongTextDescriptor  = NSSortDescriptor(key: "displayLongText", ascending: true)
            fetchRequest.sortDescriptors = [positionDescriptor, displayLongTextDescriptor]
            fetchRequest.predicate  = NSPredicate(format: "list = %@", newValue!)
            fetchRequest.fetchBatchSize = 20
            self.frc = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: managedObjectContext,
                sectionNameKeyPath: nil,
                cacheName: nil)
            self.frc?.delegate = self

            do {
                try self.frc?.performFetch()
                self.tableView?.reloadData()
            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }
        }
        didSet {
        }
    }

    func configureFetch() {

        if list == nil {
            return
        }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Task")
        let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
        let displayLongTextDescriptor  = NSSortDescriptor(key: "displayLongText", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, displayLongTextDescriptor]
        fetchRequest.predicate  = NSPredicate(format: "list = %@ AND archivedAt != nil", self.list!)
        fetchRequest.fetchBatchSize = 20
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

    override func viewDidLoad() {
        super.viewDidLoad()

        configureFetch()

        self.title = "Archive"

        setupNavigationBarProperties()

        tableView?.backgroundColor = UIColor(named: "mainColor")
        tableView?.separatorColor = UIColor(named: "tableViewSeparator")
        tableView?.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView?.register(TaskTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = GenericTableViewCell.cellHeight
        tableView?.tableFooterView = UIView()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(ArchivedTasksViewController.close(_:)))

        self.view.addSubview(self.noTasksLabel!)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ArchivedTasksViewController.onChangeSize(_:)),
            name: UIContentSizeCategory.didChangeNotification, object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ArchivedTasksViewController.deviceOrientationChanged),
            name: UIDevice.orientationDidChangeNotification, object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ArchivedTasksViewController.syncActivityDidEndNotification(_:)),
            name: NSNotification.Name.IDMSyncActivityDidEnd, object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ArchivedTasksViewController.syncActivityDidBeginNotification(_:)),
            name: NSNotification.Name.IDMSyncActivityDidBegin, object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ArchivedTasksViewController.appBecomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ArchivedTasksViewController.updateFonts),
            name: NSNotification.Name(
                rawValue: Notifications.fontDidChangeNotification), object: nil)
    }

    @objc func updateFonts() {
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

    @objc func deviceOrientationChanged() {
        if UIDevice.current.orientation.isLandscape {
            self.orientation = "landscape"
        }
        if UIDevice.current.orientation.isPortrait {
            self.orientation = "portrait"
        }

        self.noTasksLabel!.frame = CGRect(
            x: self.view.frame.size.width / 2.0 - self.view.frame.size.width / 2.0,
            y: self.view.frame.size.height / 2.0 - 44.0 / 2.0,
            width: self.view.frame.size.width,
            height: 44.0)
    }

    override func loadView() {
        super.loadView()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if UIDevice.current.orientation.isLandscape {
            self.orientation = "landscape"
        }
        if UIDevice.current.orientation.isPortrait {
            self.orientation = "portrait"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkForTasks()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setEditing(false, animated: false)
    }

    func displayArchive(_ button: ArchiveButton) {
        let vc: ArchivedListsViewController = ArchivedListsViewController(managedObjectContext: managedObjectContext)
        let nc: UINavigationController = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        navigationController?.present(nc, animated: true, completion: nil)
    }

    // MARK: Close

    @objc func close(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    func checkForTasks() {
        if let fetchedObjects = self.frc?.fetchedObjects {
            if fetchedObjects.isEmpty {
                self.noTasksLabel?.isHidden = false
            } else {
                self.noTasksLabel?.isHidden = true
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tasksFooterView?.frame = CGRect(
            x: 0.0,
            y: self.view.frame.size.height - 51.0,
            width: self.view.frame.size.width,
            height: 51.0)

        noTasksLabel!.frame = CGRect(
            x: self.view.frame.size.width / 2.0 - self.view.frame.size.width / 2.0,
            y: self.view.frame.size.height / 2.0 - 44.0 / 2.0,
            width: self.view.frame.size.width,
            height: 44.0)
    }

    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(
            style: UITableViewRowAction.Style.default,
            title: "Delete",
            handler: {_, indexpath in
                if let task: TLITask = self.frc?.object(at: indexpath) as? TLITask {
                    // Delete the core date entity
                    self.managedObjectContext.delete(task)
                    // swiftlint:disable force_try
                    try! self.managedObjectContext.save()
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
                    try! self.managedObjectContext.save()
                }
                self.checkForTasks()
                self.setEditing(false, animated: true)
                self.tableView?.reloadData()
        })
        restoreRowAction.backgroundColor = UIColor.tinylogMainColor
        return [restoreRowAction, deleteRowAction]
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func taskAtIndexPath(_ indexPath: IndexPath) -> TLITask? {
        if let task = self.frc?.object(at: indexPath) as? TLITask {
            return task
        }
        return nil
    }

    func updateTask(_ task: TLITask, sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        var fetchedTasks: [AnyObject] = (self.frc?.fetchedObjects)!
        // Remove current list item
        fetchedTasks = fetchedTasks.filter { $0 as! TLITask != task }

        var sortedIndex = destinationIndexPath.row

        for sectionIndex in 0..<destinationIndexPath.section {
            sortedIndex += (self.frc?.sections?[sectionIndex].numberOfObjects)!

            if sectionIndex == sourceIndexPath.section {
                sortedIndex -= 1
            }
        }

        fetchedTasks.insert(task, at: sortedIndex)

        for(index, task) in fetchedTasks.enumerated() {
            let tmpTask = task as! TLITask
            tmpTask.position = fetchedTasks.count-index as NSNumber
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
        let task = self.taskAtIndexPath(sourceIndexPath)!
        updateTask(task, sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)

        try! managedObjectContext.save()
    }

    @objc func onChangeSize(_ notification: Notification) {
        self.tableView?.reloadData()
    }

    override func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        if let task: TLITask = self.frc?.object(at: indexPath) as? TLITask,
            let taskTableViewCell: TaskTableViewCell = cell as? TaskTableViewCell {
            taskTableViewCell.managedObjectContext = managedObjectContext
            taskTableViewCell.task = task
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell: TaskTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: kCellIdentifier) as! TaskTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.taskLabel.delegate = self
            configureCell(cell, atIndexPath: indexPath)
            return cell

    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

    // MARK: Edit Task
    func editTask(_ task: TLITask, indexPath: IndexPath) {
        let editTaskViewController: EditTaskViewController = EditTaskViewController()
        editTaskViewController.managedObjectContext = managedObjectContext
        editTaskViewController.task = task
        editTaskViewController.indexPath = indexPath
        editTaskViewController.delegate = self
        let nc: UINavigationController = UINavigationController(rootViewController: editTaskViewController)
        nc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.navigationController?.present(nc, animated: true, completion: nil)
    }

    func onClose(_ editTaskViewController: EditTaskViewController, indexPath: IndexPath) {
        self.currentIndexPath = indexPath
        self.tableView?.reloadData()
    }

    func exportTasks(_ sender: UIButton) {

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Task")
        let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
        let displayLongTextDescriptor  = NSSortDescriptor(key: "displayLongText", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, displayLongTextDescriptor]
        fetchRequest.predicate  = NSPredicate(format: "list = %@", self.list!)
        fetchRequest.fetchBatchSize = 20

        do {
            let tasks: NSArray = try managedObjectContext.fetch(fetchRequest) as NSArray

            var output: NSString = ""

            let listTitle: NSString = self.list!.title! as NSString
            output = output.appending(NSString(format: "%@\n", listTitle) as String) as NSString

            for task in tasks {
                if let taskItem: TLITask = task as? TLITask,
                    let displayLongText = taskItem.displayLongText {
                    let displayLongText: NSString = NSString(format: "- %@\n", displayLongText)
                    output = output.appending(displayLongText as String) as NSString
                }
            }

            let activityViewController: UIActivityViewController = UIActivityViewController(
                activityItems: [output],
                applicationActivities: nil)
            activityViewController.excludedActivityTypes =  [
                UIActivity.ActivityType.postToTwitter,
                UIActivity.ActivityType.postToFacebook,
                UIActivity.ActivityType.postToWeibo,
                UIActivity.ActivityType.copyToPasteboard,
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.addToReadingList,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType.postToTencentWeibo
            ]
            self.navigationController?.present(activityViewController, animated: true, completion: nil)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
}

extension ArchivedTasksViewController: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        UIApplication.shared.open(link,
                                  options: [:],
                                  completionHandler: nil)
    }
}
