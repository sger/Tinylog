//
//  HelpTableViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class HelpTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    let helpCellIdentifier = "HelpTableViewCell"
    var data = [localizedString(key: "Help_instructions1"),
                localizedString(key: "Help_instructions2"),
                localizedString(key: "Help_instructions3"),
                localizedString(key: "Help_instructions4"),
                localizedString(key: "Help_instructions5"),
                localizedString(key: "Help_instructions6"),
                localizedString(key: "Help_instructions7"),
                localizedString(key: "Help_instructions8"),
                localizedString(key: "Help_instructions9"),
                localizedString(key: "Help_instructions10"),
                localizedString(key: "Help_instructions11"),
                localizedString(key: "Help_instructions12"),
                localizedString(key: "Help_instructions13"),
                localizedString(key: "Help_instructions14"),
                localizedString(key: "Help_instructions15"),
                localizedString(key: "Help_instructions16")]

    // MARK: Initializers

    override init(style: UITableView.Style) {
        super.init(style: UITableView.Style.plain)
    }

    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBarProperties()

        tableView?.backgroundColor = UIColor(named: "mainColor")
        tableView?.backgroundView = UIView()
        tableView?.backgroundView?.backgroundColor = UIColor.clear
        tableView?.separatorColor = UIColor(named: "tableViewSeparator")
        tableView?.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView?.register(HelpTableViewCell.self, forCellReuseIdentifier: helpCellIdentifier)
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 60

        title = "Help"

        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(HelpTableViewController.updateFonts),
                                               name: NSNotification.Name(
                                                rawValue: Notifications.fontDidChangeNotification),
                                               object: nil)
    }

    @objc func updateFonts() {
        self.navigationController?.navigationBar.setNeedsDisplay()
    }

    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        if let helpTableViewCell: HelpTableViewCell = cell as? HelpTableViewCell {
            helpTableViewCell.helpLabel.text = data[indexPath.row]
        }
    }

    // MARK: Actions

    func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HelpTableViewCell = tableView.dequeue(for: indexPath)
        configureCell(cell, indexPath: indexPath)
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
    }
}
