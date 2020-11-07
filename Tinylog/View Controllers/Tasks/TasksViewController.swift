//
//  TasksViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import Nantes
// swiftlint:disable force_unwrapping
protocol TasksViewControllerDelegate: AnyObject {
    func tasksViewControllerDidTapArchives(_ viewController: TasksViewController, list: TLIList?)
}

final class TasksViewController: CoreDataTableViewController, AddTaskViewDelegate, EditTaskViewControllerDelegate {

    weak var delegate: TasksViewControllerDelegate?

    private let managedObjectContext: NSManagedObjectContext

    private var viewModel: TasksViewModel?

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

    private var currentIndexPath: IndexPath?

    private var tasksFooterView: TasksFooterView = {
        let tasksFooterView = TasksFooterView()
        return tasksFooterView
    }()

    private var enableDidSelectRowAtIndexPath = true

    private lazy var addTransparentLayer: UIView = {
        let addTransparentLayer: UIView = UIView()
        addTransparentLayer.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleBottomMargin]
        addTransparentLayer.backgroundColor = UIColor(named: "transparencyLayerColor")
        addTransparentLayer.alpha = 0.0
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(TasksViewController.transparentLayerTapped(_:)))
        addTransparentLayer.addGestureRecognizer(tapGestureRecognizer)
        return addTransparentLayer
    }()

    private lazy var noTasksLabel: UILabel = {
        let noTasksLabel: UILabel = UILabel()
        noTasksLabel.font = UIFont.regularFontWithSize(18.0)
        noTasksLabel.textColor = UIColor(named: "textColor")
        noTasksLabel.text = "Tap text field to create a new task."
        noTasksLabel.isHidden = true
        return noTasksLabel
    }()

    private lazy var noListSelected: UILabel = {
        let noListSelected: UILabel = UILabel()
        noListSelected.font = UIFont.regularFontWithSize(16.0)
        noListSelected.textColor = UIColor(named: "textColor")
        noListSelected.textAlignment = NSTextAlignment.center
        noListSelected.text = "No List Selected"
        noListSelected.sizeToFit()
        noListSelected.isHidden = true
        return noListSelected
    }()

    private lazy var addTaskView: AddTaskView = {
        let header: AddTaskView = AddTaskView(
            frame: CGRect(
                x: 0.0,
                y: 0.0,
                width: self.tableView!.bounds.size.width,
                height: AddTaskView.height))
        header.closeButton.addTarget(
            self,
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

        addTransparentLayer.snp.makeConstraints({ (make) in
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
        self.tableView?.reloadData()
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

        // Fetch all objects from list
        let fetchRequestTotal: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Task")
        let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
        fetchRequestTotal.sortDescriptors = [positionDescriptor]
        fetchRequestTotal.predicate  = NSPredicate(format: "archivedAt = nil AND list = %@", list)
        fetchRequestTotal.fetchBatchSize = 20

        do {
            let results: NSArray = try managedObjectContext.fetch(fetchRequestTotal) as NSArray

            let fetchRequestCompleted: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
                entityName: "Task")
            fetchRequestCompleted.sortDescriptors = [positionDescriptor]
            fetchRequestCompleted.predicate  = NSPredicate(
                format: "archivedAt = nil AND completed = %@ AND list = %@",
                NSNumber(value: false as Bool), list)
            fetchRequestCompleted.fetchBatchSize = 20
            let resultsCompleted: NSArray = try managedObjectContext.fetch(fetchRequestCompleted) as NSArray

            let total: Int = results.count - resultsCompleted.count

            if total == results.count {
                tasksFooterView.updateInfoLabel("All tasks completed")
            } else {
                if total > 1 {
                    tasksFooterView.updateInfoLabel("\(total) completed tasks")
                } else {
                    tasksFooterView.updateInfoLabel("\(total) completed task")
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
        view.addSubview(addTransparentLayer)

        view.setNeedsUpdateConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.checkForEmptyResults() {
            self.noTasksLabel.isHidden = false
        } else {
            self.noTasksLabel.isHidden = true
        }
        self.tableView?.reloadData()

        // TODO remove this reference
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
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Done",
                style: UIBarButtonItem.Style.plain,
                target: self,
                action: #selector(TasksViewController.toggleEditMode(_:)))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
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
                if let task: TLITask = self.frc?.object(at: indexpath) as? TLITask {
                    task.archivedAt = Date()
                    // Update counter list
                    // Fetch all objects from list
                    let fetchRequestTotal: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
                        entityName: "Task")
                    let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
                    fetchRequestTotal.sortDescriptors = [positionDescriptor]
                    fetchRequestTotal.predicate  = NSPredicate(
                        format: "archivedAt = nil AND list = %@", task.list!)
                    fetchRequestTotal.fetchBatchSize = 20
                    do {
                        let results: NSArray = try self.managedObjectContext.fetch(fetchRequestTotal)
                            as NSArray
                        let fetchRequestCompleted: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
                            entityName: "Task")
                        fetchRequestCompleted.sortDescriptors = [positionDescriptor]
                        fetchRequestCompleted.predicate  = NSPredicate(
                            format: "archivedAt = nil AND completed = %@ AND list = %@",
                            NSNumber(value: true as Bool), task.list!)
                        fetchRequestCompleted.fetchBatchSize = 20
                        let resultsCompleted: NSArray = try self.managedObjectContext.fetch(
                            fetchRequestCompleted) as NSArray
                        let total: Int = results.count - resultsCompleted.count
                        task.list!.total = total as NSNumber?
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
        if let task = self.frc?.object(at: indexPath) as? TLITask {
            return task
        }
        return nil
    }

    // swiftlint:disable force_cast
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
        // swiftlint:disable force_try
        try! managedObjectContext.save()
    }

    @objc func onChangeSize(_ notification: Notification) {
        self.tableView?.reloadData()
    }

    override func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let task: TLITask = self.frc?.object(at: indexPath) as! TLITask
        let taskTableViewCell: TaskTableViewCell = cell as! TaskTableViewCell
        taskTableViewCell.managedObjectContext = managedObjectContext
        taskTableViewCell.task = task
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if enableDidSelectRowAtIndexPath {
            return addTaskView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if enableDidSelectRowAtIndexPath {
            return AddTaskView.height
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TaskTableViewCell = tableView.dequeue(for: indexPath)
        cell.checkBoxButton.addTarget(self,
                                      action: #selector(TasksViewController.toggleComplete(_:)),
                                      for: UIControl.Event.touchUpInside)
        cell.taskLabel.delegate = self
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if enableDidSelectRowAtIndexPath {

            let task: TLITask = self.frc?.object(at: indexPath) as! TLITask

            DispatchQueue.main.async {
                self.editTask(task, indexPath: indexPath)
            }
        }
    }

    @objc func toggleComplete(_ button: CheckBoxButton) {
        guard let list = list else {
            return
        }
        if enableDidSelectRowAtIndexPath {

            let button: CheckBoxButton = button as CheckBoxButton
            let indexPath: IndexPath? = self.tableView?.indexPath(for: button.tableViewCell!)!

            if !(indexPath != nil) {
                return
            }

            let task: TLITask = self.frc?.object(at: indexPath!) as! TLITask

            if task.completed?.boolValue == true {
                task.completed = NSNumber(value: false as Bool)
                task.checkBoxValue = "false"
                task.completedAt = nil
            } else {
                task.completed = NSNumber(value: true as Bool)
                task.checkBoxValue = "true"
                task.completedAt = Date()
            }

            task.updatedAt = Date()

            let animation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = NSNumber(value: 1.4 as Float)
            animation.toValue = NSNumber(value: 1.0 as Float)
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.3, 1, 1)
            button.layer.add(animation, forKey: "bounceAnimation")

            try? managedObjectContext.save()

            updateFooterInfoText(list)
        }
    }

    // MARK: AddTaskViewDelegate

    func addTaskViewDidBeginEditing(_ addTaskView: AddTaskView) {
        displayTransparentLayer()
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
                task.checkBoxValue = "false"
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

    private func displayTransparentLayer() {
        self.tableView?.isScrollEnabled = false
        let addTransparentLayer: UIView = self.addTransparentLayer
        UIView.animate(withDuration: 0.3, delay: 0.0,
            options: .allowUserInteraction, animations: {
                addTransparentLayer.alpha = 1.0
            }, completion: nil)
    }

    private func hideTransparentLayer() {
        self.tableView?.isScrollEnabled = true
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: UIView.AnimationOptions.allowUserInteraction,
            animations: {
                self.addTransparentLayer.alpha = 0.0
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

    func onClose(_ editTaskViewController: EditTaskViewController, indexPath: IndexPath) {
        self.currentIndexPath = indexPath
        self.tableView?.reloadData()
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

extension TasksViewController: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        UIApplication.shared.open(link,
                                  options: [:],
                                  completionHandler: nil)
    }
}
