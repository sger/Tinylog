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

        view.backgroundColor = UIColor.tinylogLightGray
        tableView?.backgroundView = UIView()
        tableView?.backgroundView?.backgroundColor = UIColor.clear
        tableView?.backgroundColor = UIColor.tinylogLightGray
        tableView?.separatorColor = UIColor(named: "tableViewSeparator")
        tableView?.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView?.register(ListTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 60
        tableView?.tableFooterView = UIView()
        
        view.addSubview(noResultsLabel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNoResults()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView?.frame = CGRect(x: 0.0, y: 0.0,
                                  width: view.frame.size.width,
                                  height: view.frame.size.height)
    }

    func configureFetch() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "List")
        let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
        let remoteIDDescriptor  = NSSortDescriptor(key: "remoteID", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, remoteIDDescriptor]
        frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        frc?.delegate = self
    }

    override func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        if let list: TLIList = frc?.object(at: indexPath) as? TLIList,
            let listTableViewCell: ListTableViewCell = cell as? ListTableViewCell {
                listTableViewCell.currentList = list
        }
    }

    // swiftlint:disable force_cast
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier) as? ListTableViewCell {
            configureCell(cell, atIndexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
}

extension ResultsTableViewController {
    func showNoResults() {
        if checkForEmptyResults() {
            noResultsLabel.isHidden = false
        } else {
            noResultsLabel.isHidden = true
        }
    }
}
