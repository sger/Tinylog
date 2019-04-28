//
//  CoreDataTableViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import CoreData

class CoreDataTableViewController: UIViewController, UITableViewDataSource,
    UITableViewDelegate, NSFetchedResultsControllerDelegate {

    var tableView: UITableView?
    var frc: NSFetchedResultsController<NSFetchRequestResult>?
    var debug: Bool? = true
    var ignoreNextUpdates: Bool = false

    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView?.dataSource = self
        tableView?.delegate = self
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        tableView?.dataSource = nil
        tableView?.delegate = nil
    }
    // swiftlint:disable force_unwrapping
    override func loadView() {
        super.loadView()
        tableView?.frame = self.view.bounds
        self.view.addSubview(tableView!)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView?.flashScrollIndicators()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView?.setEditing(editing, animated: animated)
    }

    class func classString() -> String {
        return NSStringFromClass(self)
    }

    // swiftlint:disable line_length
    func performFetch() {
        if debug! {
            print("Running \(NSStringFromClass(CoreDataTableViewController.self)) \(NSStringFromSelector(#function))")
        }

        if self.frc != nil {

            self.frc?.managedObjectContext.perform({ () -> Void in
                do {
                    try self.frc!.performFetch()
                    self.tableView?.reloadData()
                } catch let error as NSError {
                    print("Failed to perform fetch \(error)")
                }
            })

        } else {
            print("Failed to fetch the NSFetchedResultsController controller is nil")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyTestCell")
        return cell
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.frc?.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = frc!.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    /*func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
     return self.frc?.sections![section].name
    }*/

    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.frc!.section(forSectionIndexTitle: title, at: index)
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.frc?.sectionIndexTitles
    }

    // MARK: - NSFetchedResultsControllerDelegate

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if ignoreNextUpdates {
            return
        }

        self.tableView?.beginUpdates()
    }
    // swiftlint:disable unneeded_break_in_switch
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {

        if ignoreNextUpdates {
            return
        }

        switch type {
        case NSFetchedResultsChangeType.insert:
            self.tableView?.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            break
        case NSFetchedResultsChangeType.delete:
            self.tableView?.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            break
        default:
            return
        }
    }
    // swiftlint:disable cyclomatic_complexity
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

            if ignoreNextUpdates {
                return
            }

            switch type {

            case .insert:
                if let newIndexPath = newIndexPath {
                    tableView?.insertRows(at: [newIndexPath],
                        with: UITableView.RowAnimation.fade)
                }

            case .delete:
                if let indexPath = indexPath {
                    tableView?.deleteRows(at: [indexPath],
                        with: UITableView.RowAnimation.fade)
                }

            case .update:
                if let indexPath = indexPath {
                    if let cell = tableView!.cellForRow(at: indexPath) {
                        self.configureCell(cell, atIndexPath: indexPath)
                    }
                }

            case .move:
                if let indexPath = indexPath {
                    if let newIndexPath = newIndexPath {
                        tableView?.deleteRows(at: [indexPath],
                            with: UITableView.RowAnimation.fade)
                        tableView?.insertRows(at: [newIndexPath],
                            with: UITableView.RowAnimation.fade)
                    }
                }
            @unknown default: break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if ignoreNextUpdates {
            ignoreNextUpdates = false
        } else {
            self.tableView?.endUpdates()
        }
    }
}
