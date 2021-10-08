//
//  AddListViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import SVProgressHUD

final class AddListViewController: UITableViewController, UITextFieldDelegate {

    enum Mode: String {
        case create
        case edit
    }

    private let managedObjectContext: NSManagedObjectContext
    private let mode: Mode
    private let list: TLIList?

    private var name: UITextField?
    private var menuColorsView: MenuColorsView?
    private var selectedColor: String = ""

    weak var delegate: AddListViewControllerDelegate?

    init(managedObjectContext: NSManagedObjectContext, list: TLIList?, mode: Mode) {
        self.managedObjectContext = managedObjectContext
        self.list = list
        self.mode = mode
        self.selectedColor = list?.color ?? ""
        super.init(style: .grouped)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBarProperties()
        setupUITableView()
        setupNavigationItem()
        setupMenuColorsView()
        setupViewMode()
    }

    private func setupUITableView() {
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor(named: "mainColor")
        tableView.separatorColor = UIColor(named: "tableViewSeparator")
        tableView.register(TextFieldCell.self,
                           forCellReuseIdentifier: TextFieldCell.cellIdentifier)
    }

    private func setupNavigationItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(AddListViewController.cancel(_:)))

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(AddListViewController.save(_:)))
    }

    private func setupMenuColorsView() {
        menuColorsView = MenuColorsView(frame: CGRect(x: 12.0, y: 0.0, width: view.frame.width, height: 51.0))
        menuColorsView?.delegate = self
        tableView.tableFooterView = menuColorsView
    }

    private func setupViewMode() {
        switch mode {
        case .create:
            title = "Add List"
            view.accessibilityIdentifier = "AddList"
        case .edit:
            title = "Edit List"
            view.accessibilityIdentifier = "EditList"
            menuColorsView?.configure(with: list)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        name?.becomeFirstResponder()
    }

    @objc func cancel(_ button: UIButton) {
        name?.resignFirstResponder()
        delegate?.addListViewControllerDismissed(self)
    }

    @objc func save(_ button: UIButton) {
        createOrEditList()
    }

    override func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath) {
        if let textFieldCell: TextFieldCell = cell as? TextFieldCell {
            if indexPath.row == 0 {
                if let list = list {
                    textFieldCell.textField?.text = list.title
                } else {
                    textFieldCell.textField?.text = ""
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TextFieldCell = tableView.dequeue(for: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    private func configureCell(_ cell: TextFieldCell, atIndexPath indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.textField?.placeholder = "Name"
            cell.backgroundColor = UIColor(named: "mainColor")
            cell.textField?.returnKeyType = .go
            cell.textField?.delegate = self
            name = cell.textField
            return
        }
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == name {
            createOrEditList()
        }
        return false
    }

    private func saveList() {
        if let list = list {
            list.title = name?.text
            list.color = selectedColor

            try? managedObjectContext.save()
            name?.resignFirstResponder()
            delegate?.addListViewController(self, didSucceedWithList: list)
        }
    }

    private func createOrEditList() {
        if let text = name?.text, text.isEmpty {
            SVProgressHUD.show()
            SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
            SVProgressHUD.setBackgroundColor(UIColor.tinylogMainColor)
            SVProgressHUD.setForegroundColor(UIColor.white)
            if let font = UIFont(name: "HelveticaNeue", size: 14.0) {
                SVProgressHUD.setFont(font)
            }
            SVProgressHUD.showError(withStatus: "Please add a name to your list")
        } else {
            switch mode {
            case .create:
                createList()
            case .edit:
                saveList()
            }
        }
    }

    private func createList() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "List")
        let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
        fetchRequest.sortDescriptors = [positionDescriptor]
        fetchRequest.fetchLimit = 1

        do {
            var position: Int = 0
            if let results = try managedObjectContext.fetch(fetchRequest) as? [TLIList] {
                if results.isEmpty {
                    position = 0
                } else {
                    if let pos = results[0].position {
                        position = pos.intValue
                    }
                }
            }

            if let list: TLIList = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                                       into: managedObjectContext) as? TLIList {
                if let name = name {
                    list.title = name.text
                }
                list.position = NSNumber(value: position + 1)
                if selectedColor.isEmpty {
                    selectedColor = "#6a6de2"
                }
                list.color = selectedColor

                list.createdAt = Date()
                try? managedObjectContext.save()
                name?.resignFirstResponder()
                delegate?.addListViewController(self, didSucceedWithList: list)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
}

// MARK: - MenuColorsViewDelegate

extension AddListViewController: MenuColorsViewDelegate {
    func menuColorsViewDidSelectColor(_ view: MenuColorsView, selectedColor color: String?) {
        guard let color = color else {
            return
        }
        selectedColor = color
    }
}
