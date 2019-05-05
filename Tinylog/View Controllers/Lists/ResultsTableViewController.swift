//
//  ResultsTableViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class ResultsTableViewController: CoreDataTableViewController {

    let kCellIdentifier = "CellIdentifier"
    var managedObjectContext: NSManagedObjectContext!

    lazy var noResultsLabel: UILabel = {
        let noResultsLabel: UILabel = UILabel()
        noResultsLabel.font = UIFont.tinylogFontOfSize(16.0)
        noResultsLabel.textColor = UIColor.tinylogTextColor
        noResultsLabel.textAlignment = NSTextAlignment.center
        noResultsLabel.text = "No Results"
        noResultsLabel.frame = CGRect(
            x: self.view.frame.size.width / 2.0 - self.view.frame.size.width / 2.0,
            y: self.view.frame.size.height / 2.0 - 44.0 / 2.0,
            width: self.view.frame.size.width,
            height: 44.0)
        return noResultsLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.tinylogLightGray
        self.tableView?.backgroundColor = UIColor.tinylogLightGray
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView?.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height)
        self.tableView?.register(ListTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        self.tableView?.rowHeight = UITableView.automaticDimension
        self.tableView?.estimatedRowHeight = GenericTableViewCell.cellHeight
        self.view.addSubview(self.noResultsLabel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.checkForEmptyResults() {
            self.noResultsLabel.isHidden = false
        } else {
            self.noResultsLabel.isHidden = true
        }
    }

    func configureFetch() {

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "List")
        let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
        let remoteIDDescriptor  = NSSortDescriptor(key: "remoteID", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, remoteIDDescriptor]
        self.frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        self.frc?.delegate = self
    }

    override func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        if let list: TLIList = self.frc?.object(at: indexPath) as? TLIList,
            let listTableViewCell: ListTableViewCell = cell as? ListTableViewCell {
                listTableViewCell.currentList = list
        }
    }

    // swiftlint:disable force_cast
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier) as! ListTableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
}
