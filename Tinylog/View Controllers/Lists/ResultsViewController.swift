//
//  ResultsViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

final class ResultsViewController: CoreDataTableViewController {

    var managedObjectContext: NSManagedObjectContext!

    lazy var noResultsLabel: UILabel = {
        let noResultsLabel: UILabel = UILabel()
        noResultsLabel.font = UIFont.tinylogFontOfSize(16.0)
        noResultsLabel.textColor = UIColor.tinylogTextColor
        noResultsLabel.textAlignment = NSTextAlignment.center
        noResultsLabel.text = localizedString(key: "No_results")
        return noResultsLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        tableView?.backgroundColor = UIColor.white
        tableView?.backgroundView = UIView()
        tableView?.backgroundView?.backgroundColor = UIColor.clear
        tableView?.backgroundColor = UIColor.tinylogLightGray
        tableView?.separatorColor = UIColor(named: "tableViewSeparator")
        tableView?.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView?.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.cellIdentifier)
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 60
        tableView?.tableFooterView = UIView()

        view.addSubview(noResultsLabel)

        noResultsLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

        tableView?.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(view)
            make.right.equalTo(view)
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNoResults()
    }

    func configureFetch() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "List")
        let positionDescriptor = NSSortDescriptor(key: "position", ascending: false)
        let remoteIDDescriptor = NSSortDescriptor(key: "remoteID", ascending: true)
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
                listTableViewCell.list = list
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ListTableViewCell = tableView.dequeue(for: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
}

extension ResultsViewController {
    func showNoResults() {
        if checkForEmptyResults() {
            noResultsLabel.isHidden = false
        } else {
            noResultsLabel.isHidden = true
        }
    }
}
