//
//  TLIHelpTableViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import MessageUI
// Consider refactoring the code to use the non-optional operators.
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}
// Consider refactoring the code to use the non-optional operators.
private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class TLIHelpTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    var estimatedRowHeightCache: NSMutableDictionary?
    let helpCellIdentifier = "HelpCellIdentifier"
    var helpArr = [
        "Create a new list by tapping Plus icon at bottom left",
        "Search all your lists with the search field at the top",
        "Search all your lists with by typing 'purple', 'blue', 'red', 'orange', 'green', 'yellow' tags",
        "Create a new task by tapping text field at the top",
        "View tasks by tapping a list",
        "View archives by tapping Archive icon at bottom right",
        "Reorder lists and tasks by tapping 'Edit'",
        "Archive a list by swiping to the left and tapping 'Archive'",
        "Edit a list by swiping to the left and tapping 'Edit'",
        "Delete a list by swiping to the left and tapping 'Delete'",
        "Restore a list by swiping to the left and tapping 'Restore'",
        "Tap checkbox to complete tasks",
        "Create web links by typing http:// for example http://www.tinylogapp.com",
        "Enable iCloud by tapping Settings icon",
        "Change font or size by tapping Settings icon",
        "Thanks for choosing Tinylog"]

    // MARK: Initializers

    override init(style: UITableViewStyle) {
        super.init(style: UITableViewStyle.plain)
    }

    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.tinylogLightGray
        self.tableView?.backgroundColor = UIColor.tinylogLightGray
        self.tableView?.backgroundView = UIView()
        self.tableView?.backgroundView?.backgroundColor = UIColor.clear
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView?.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height - 50.0)

        self.tableView?.register(TLIHelpTableViewCell.self, forCellReuseIdentifier: helpCellIdentifier)
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 61

        self.title = "Help"
        // swiftlint:disable force_unwrapping
        self.navigationController?.interactivePopGestureRecognizer!.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TLIHelpTableViewController.updateFonts),
            name: NSNotification.Name(
                rawValue: TLINotifications.kTLIFontDidChangeNotification as String),
            object: nil)
    }

    @objc func updateFonts() {
        self.navigationController?.navigationBar.setNeedsDisplay()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initEstimatedRowHeightCacheIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        if let helpTableViewCell: TLIHelpTableViewCell = cell as? TLIHelpTableViewCell {
            helpTableViewCell.helpLabel.text = helpArr[indexPath.row]
        }
    }

    // MARK: Actions

    func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return floor(getEstimatedCellHeightFromCache(indexPath, defaultHeight: 61)!)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpArr.count
    }
    // swiftlint:disable force_cast
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: helpCellIdentifier) as! TLIHelpTableViewCell
        self.configureCell(cell, indexPath: indexPath)

        let success = isEstimatedRowHeightInCache(indexPath)

        if success != nil {
            let cellSize: CGSize = cell.systemLayoutSizeFitting(
                CGSize(width: self.view.frame.size.width, height: 0),
                withHorizontalFittingPriority: UILayoutPriority(rawValue: 1000),
                verticalFittingPriority: UILayoutPriority(rawValue: 61))
            putEstimatedCellHeightToCache(indexPath, height: cellSize.height)
        }

        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}

    func putEstimatedCellHeightToCache(_ indexPath: IndexPath, height: CGFloat) {
        initEstimatedRowHeightCacheIfNeeded()
        estimatedRowHeightCache?.setValue(height, forKey: NSString(format: "%ld", indexPath.row) as String)
    }

    func initEstimatedRowHeightCacheIfNeeded() {
        if estimatedRowHeightCache == nil {
            estimatedRowHeightCache = NSMutableDictionary()
        }
    }

    func getEstimatedCellHeightFromCache(_ indexPath: IndexPath, defaultHeight: CGFloat) -> CGFloat? {
        initEstimatedRowHeightCacheIfNeeded()

        let height: CGFloat? = estimatedRowHeightCache!.value(
            forKey: NSString(format: "%ld", indexPath.row) as String) as? CGFloat

        if height != nil {
            return floor(height!)
        }
        return defaultHeight
    }

    func isEstimatedRowHeightInCache(_ indexPath: IndexPath) -> Bool? {
        let value = getEstimatedCellHeightFromCache(indexPath, defaultHeight: 0)
        if value > 0 {
            return true
        }
        return false
    }
}
