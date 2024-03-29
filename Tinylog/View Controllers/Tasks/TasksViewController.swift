//
//  TasksViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import Nantes

protocol TasksViewControllerDelegate: AnyObject {
    func tasksViewControllerDidTapArchives(_ viewController: TasksViewController, list: TLIList?)
}

final class TasksViewController: CoreDataTableViewController, AddTaskViewDelegate, EditTaskViewControllerDelegate {

    weak var delegate: TasksViewControllerDelegate?

    var list: TLIList? {
        didSet {
            guard let list = list else {
                noListSelected.isHidden = false
                return
            }

            noListSelected.isHidden = true
            title = list.title
            configureFetch()

            if checkForEmptyResults() {
                noTasksLabel.isHidden = false
            } else {
                noTasksLabel.isHidden = true
            }
            updateFooterInfoText(list)
        }
    }

    private let managedObjectContext: NSManagedObjectContext
    private var viewModel: TasksViewModel?

    private var tasksFooterView: TasksFooterView = {
        let tasksFooterView = TasksFooterView()
        return tasksFooterView
    }()

    private lazy var transparentLayer: UIView = {
        let transparentLayer: UIView = UIView()
        transparentLayer.backgroundColor = UIColor(named: "transparencyLayerColor")
        transparentLayer.alpha = 0.0
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(TasksViewController.transparentLayerTapped(_:)))
        transparentLayer.addGestureRecognizer(tapGestureRecognizer)
        return transparentLayer
    }()

    private lazy var noTasksLabel: UILabel = {
        let noTasksLabel: UILabel = UILabel()
        noTasksLabel.font = UIFont.regularFontWithSize(18.0)
        noTasksLabel.textColor = UIColor(named: "textColor")
        noTasksLabel.text = localizedString(key: "Create_task")
        noTasksLabel.isHidden = true
        return noTasksLabel
    }()

    private lazy var noListSelected: UILabel = {
        let noListSelected: UILabel = UILabel()
        noListSelected.font = UIFont.regularFontWithSize(16.0)
        noListSelected.textColor = UIColor(named: "textColor")
        noListSelected.textAlignment = NSTextAlignment.center
        noListSelected.text = localizedString(key: "No_list_selected")
        noListSelected.sizeToFit()
        noListSelected.isHidden = true
        return noListSelected
    }()

    private lazy var addTaskView: AddTaskView = {
        let header = AddTaskView()
        header.closeButton.addTarget(self,
                                     action: #selector(TasksViewController.transparentLayerTapped(_:)),
                                     for: UIControl.Event.touchDown)
        header.delegate = self
        return header
    }()

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureFetch() {
        guard let list = list else {
            return
        }
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Task")
        let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
        let displayLongTextDescriptor  = NSSortDescriptor(key: "displayLongText", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, displayLongTextDescriptor]
        fetchRequest.predicate  = NSPredicate(format: "list = %@ AND archivedAt = nil", list)
        fetchRequest.fetchBatchSize = 20
        self.frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        self.frc?.delegate = self

        do {
            try self.frc?.performFetch()
            tableView?.reloadData()
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBarProperties()

        viewModel = TasksViewModel(managedObjectContext: managedObjectContext)

        tableView?.backgroundColor = UIColor(named: "mainColor")
        tableView?.separatorColor = UIColor(named: "tableViewSeparator")
        tableView?.separatorInset = UIEdgeInsets(top: 0, left: 22.0, bottom: 0, right: 0)
        tableView?.register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskTableViewCell")
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = GenericTableViewCell.cellHeight
        tableView?.tableFooterView = UIView()
        tableView?.translatesAutoresizingMaskIntoConstraints = false

        tableView?.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-60)
            make.left.equalTo(view)
            make.right.equalTo(view)
        })

        tasksFooterView.snp.makeConstraints { (make) in
            make.left.equalTo(view)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.width.equalTo(view)
            make.height.equalTo(60.0)
        }

        noListSelected.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
        })

        noTasksLabel.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
        })

        transparentLayer.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(AddTaskView.height)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-60)
            make.left.equalTo(view)
            make.right.equalTo(view)
        })

        tasksFooterView.exportTasksButton.addTarget(
            self,
            action: #selector(TasksViewController.exportTasks(_:)),
            for: UIControl.Event.touchDown)
        tasksFooterView.archiveButton.addTarget(
            self,
            action: #selector(TasksViewController.displayArchive(_:)),
            for: UIControl.Event.touchDown)

        setEditing(false, animated: false)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TasksViewController.onChangeSize(_:)),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TasksViewController.syncActivityDidEndNotification(_:)),
            name: NSNotification.Name.IDMSyncActivityDidEnd,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TasksViewController.syncActivityDidBeginNotification(_:)),
            name: NSNotification.Name.IDMSyncActivityDidBegin,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TasksViewController.appBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TasksViewController.updateFonts),
            name: NSNotification.Name(
                rawValue: Notifications.fontDidChangeNotification),
            object: nil)
    }

    @objc private func updateFonts() {
        tableView?.reloadData()
    }

    @objc private func appBecomeActive() {
        startSync()
    }

    private func startSync() {
        let syncManager: TLISyncManager = TLISyncManager.shared()
        if syncManager.canSynchronize() {
            syncManager.synchronize { (_) -> Void in
            }
        }
    }

    private func updateFooterInfoText(_ list: TLIList) {
        let fetchRequestTotal: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Task")
        let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
        fetchRequestTotal.sortDescriptors = [positionDescriptor]
        fetchRequestTotal.predicate = NSPredicate(format: "archivedAt = nil AND list = %@", list)
        fetchRequestTotal.fetchBatchSize = 20

        do {
            let results: NSArray = try managedObjectContext.fetch(fetchRequestTotal) as NSArray

            let fetchRequestCompleted: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
                entityName: "Task")
            fetchRequestCompleted.sortDescriptors = [positionDescriptor]
            fetchRequestCompleted.predicate  = NSPredicate(
                format: "archivedAt = nil AND completed = %@ AND list = %@",
                NSNumber(value: false), list)
            fetchRequestCompleted.fetchBatchSize = 20
            let resultsCompleted: NSArray = try managedObjectContext.fetch(fetchRequestCompleted) as NSArray

            let total: Int = results.count - resultsCompleted.count

            if total == results.count {
                tasksFooterView.updateInfoLabel(localizedString(key: "All_tasks_completed"))
            } else {
                if total == 0 {
                    tasksFooterView.updateInfoLabel(localizedString(key: "All_tasks_uncompleted"))
                } else if total > 1 {
                    tasksFooterView.updateInfoLabel(String(format: localizedString(key: "Completed_tasks"), String(total)))
                } else {
                    tasksFooterView.updateInfoLabel(String(format: localizedString(key: "Completed_task"), String(total)))
                }
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    @objc private func syncActivityDidEndNotification(_ notification: Notification) {
        if TLISyncManager.shared().canSynchronize() {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if self.checkForEmptyResults() {
                self.noTasksLabel.isHidden = false
            } else {
                self.noTasksLabel.isHidden = true
            }
            self.tableView?.reloadData()

            if let list = self.list {
                updateFooterInfoText(list)
            }
        }
    }

    @objc private func syncActivityDidBeginNotification(_ notification: Notification) {
        if TLISyncManager.shared().canSynchronize() {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            if self.checkForEmptyResults() {
                self.noTasksLabel.isHidden = false
            } else {
                self.noTasksLabel.isHidden = true
            }
            self.tableView?.reloadData()
        }
    }

    override func loadView() {
        super.loadView()

        view.addSubview(noListSelected)
        view.addSubview(noTasksLabel)
        view.addSubview(tasksFooterView)
        tableView?.addSubview(transparentLayer)

        view.setNeedsUpdateConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if checkForEmptyResults() {
            noTasksLabel.isHidden = false
        } else {
            noTasksLabel.isHidden = true
        }

        tableView?.reloadData()

        let IS_IPAD = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)

        if IS_IPAD {
            noListSelected.isHidden = false
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setEditing(false, animated: false)
    }

    @objc func displayArchive(_ button: ArchiveButton) {
        delegate?.tasksViewControllerDidTapArchives(self, list: list)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let list = list {
            if TLITask.numberOfUnarchivedTasks(with: managedObjectContext, list: list) == 0 {
                addTaskView.textField.becomeFirstResponder()
            }
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Done",
                style: UIBarButtonItem.Style.plain,
                target: self,
                action: #selector(TasksViewController.toggleEditMode(_:)))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Edit",
                style: UIBarButtonItem.Style.plain,
                target: self,
                action: #selector(TasksViewController.toggleEditMode(_:)))
        }
    }

    @objc func toggleEditMode(_ sender: UIBarButtonItem) {
        setEditing(!isEditing, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let archiveRowAction = UITableViewRowAction(
            style: UITableViewRowAction.Style.default,
            title: "Archive",
            handler: {_, indexpath in
                guard let task: TLITask = self.frc?.object(at: indexpath) as? TLITask,
                      let list = task.list else {
                    return
                }

                task.archivedAt = Date()

                let fetchRequestTotal: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
                    entityName: "Task")
                let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
                fetchRequestTotal.sortDescriptors = [positionDescriptor]
                fetchRequestTotal.predicate  = NSPredicate(
                    format: "archivedAt = nil AND list = %@", list)
                fetchRequestTotal.fetchBatchSize = 20
                do {
                    let results: NSArray = try self.managedObjectContext.fetch(fetchRequestTotal)
                        as NSArray
                    let fetchRequestCompleted: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
                        entityName: "Task")
                    fetchRequestCompleted.sortDescriptors = [positionDescriptor]
                    fetchRequestCompleted.predicate  = NSPredicate(
                        format: "archivedAt = nil AND completed = %@ AND list = %@",
                        NSNumber(value: true), list)
                    fetchRequestCompleted.fetchBatchSize = 20
                    let resultsCompleted: NSArray = try self.managedObjectContext.fetch(
                        fetchRequestCompleted) as NSArray
                    let total: Int = results.count - resultsCompleted.count
                    list.total = total as NSNumber?
                    try self.managedObjectContext.save()

                    if self.checkForEmptyResults() {
                        self.noTasksLabel.isHidden = false
                    } else {
                        self.noTasksLabel.isHidden = true
                    }
                    self.tableView?.reloadData()
                    self.setEditing(false, animated: true)
                } catch let error as NSError {
                    fatalError(error.localizedDescription)
                }
        })
        archiveRowAction.backgroundColor = UIColor.tinylogMainColor
        return [archiveRowAction]
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func taskAtIndexPath(_ indexPath: IndexPath) -> TLITask? {
        guard let task = frc?.object(at: indexPath) as? TLITask else {
            return nil
        }
        return task
    }

    func updateTasks(_ task: TLITask?,
                     sourceIndexPath: IndexPath,
                     destinationIndexPath: IndexPath) {
        guard let task = task else {
            return
        }

        guard var fetchedTasks: [TLITask] = frc?.fetchedObjects as? [TLITask] else {
            return
        }

        fetchedTasks = fetchedTasks.filter { $0 != task }

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

        fetchedTasks.insert(task, at: sortedIndex)

        for(index, task) in fetchedTasks.enumerated() {
            task.position = fetchedTasks.count - index as NSNumber
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

        guard let task = taskAtIndexPath(sourceIndexPath) else {
            return
        }

        updateTasks(task,
                    sourceIndexPath: sourceIndexPath,
                    destinationIndexPath: destinationIndexPath)

        try? managedObjectContext.save()
    }

    @objc func onChangeSize(_ notification: Notification) {
        tableView?.reloadData()
    }

    override func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        guard let task: TLITask = self.frc?.object(at: indexPath) as? TLITask,
              let taskTableViewCell = cell as? TaskTableViewCell else {
            return
        }
        taskTableViewCell.managedObjectContext = managedObjectContext
        taskTableViewCell.task = task
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        addTaskView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        AddTaskView.height
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TaskTableViewCell = tableView.dequeue(for: indexPath)
        cell.delegate = self
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let task: TLITask = self.frc?.object(at: indexPath) as? TLITask else {
            return
        }

        DispatchQueue.main.async {
            self.editTask(task, indexPath: indexPath)
        }
    }

    // MARK: AddTaskViewDelegate

    func addTaskViewDidBeginEditing(_ addTaskView: AddTaskView) {
        showTransparentLayer()
    }

    func addTaskViewDidEndEditing(_ addTaskView: AddTaskView) {
        hideTransparentLayer()
    }

    func addTaskView(_ addTaskView: AddTaskView, title: String) {
        guard let list = list else {
            return
        }

        do {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Task")
            let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
            fetchRequest.predicate = NSPredicate(format: "list = %@", list)
            fetchRequest.sortDescriptors = [positionDescriptor]
            let results: NSArray = try managedObjectContext.fetch(fetchRequest) as NSArray

            if let task: TLITask = NSEntityDescription.insertNewObject(
                forEntityName: "Task",
                into: managedObjectContext) as? TLITask {
                task.displayLongText = title as String
                task.list = list
                task.position = NSNumber(value: results.count + 1 as Int)
                task.createdAt = Date()
                task.completed = false

                try? managedObjectContext.save()
                if self.checkForEmptyResults() {
                    self.noTasksLabel.isHidden = false
                } else {
                    self.noTasksLabel.isHidden = true
                }
                self.tableView?.reloadData()
                updateFooterInfoText(list)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    private func showTransparentLayer() {
        tableView?.isScrollEnabled = false

        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .allowUserInteraction,
                       animations: {
                        self.transparentLayer.alpha = 1.0
                       }, completion: nil)
    }

    private func hideTransparentLayer() {
        tableView?.isScrollEnabled = true

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .allowUserInteraction,
                       animations: {
                        self.transparentLayer.alpha = 0.0
                       }, completion: nil)
    }

    func resetAddTaskView() {
        hideTransparentLayer()
        addTaskView.reset()
    }

    @objc private func transparentLayerTapped(_ gesture: UITapGestureRecognizer) {
        addTaskView.textField.resignFirstResponder()
    }

    // MARK: Edit Task

    private func editTask(_ task: TLITask, indexPath: IndexPath) {
        let editTaskViewController: EditTaskViewController = EditTaskViewController()
        editTaskViewController.managedObjectContext = managedObjectContext
        editTaskViewController.task = task
        editTaskViewController.indexPath = indexPath
        editTaskViewController.delegate = self
        let nc: UINavigationController = UINavigationController(rootViewController: editTaskViewController)
        nc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.navigationController?.present(nc, animated: true, completion: nil)
    }

    func onClose(_ editTaskViewController: EditTaskViewController,
                 indexPath: IndexPath) {
        tableView?.reloadData()
    }

    @objc private func exportTasks(_ sender: UIButton) {
        guard let list = list,
              let tasks = viewModel?.exportUnarchivedTasks(with: list) else {
            return
        }

        let activityViewController: UIActivityViewController = UIActivityViewController(
            activityItems: [tasks], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            .postToTwitter,
            .postToFacebook,
            .postToWeibo,
            .copyToPasteboard,
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList,
            .postToFlickr,
            .postToVimeo,
            .postToTencentWeibo
        ]

        activityViewController.modalPresentationStyle = .popover
        activityViewController.popoverPresentationController?.sourceRect = sender.bounds
        activityViewController.popoverPresentationController?.sourceView = sender
        activityViewController.popoverPresentationController?.permittedArrowDirections
            = UIPopoverArrowDirection.any

        navigationController?.present(activityViewController,
                                      animated: true,
                                      completion: nil)
    }
}

extension TasksViewController: TaskTableViewCellDelegate {
    func taskTableViewCellDidTapCheckBoxButton(_ cell: TaskTableViewCell,
                                               list: TLIList) {
        updateFooterInfoText(list)
    }
}
