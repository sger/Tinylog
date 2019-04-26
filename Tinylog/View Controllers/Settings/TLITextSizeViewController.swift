//
//  TLITextSizeViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLITextSizeViewController: TLIGroupedTableViewController, UIGestureRecognizerDelegate {
    let textSizeCellIdentifier = "TextSizeCellIdentifier"
    let numbers = [13, 14, 15, 16, 17, 18, 19, 20, 21]

    // MARK: Initializers

    override init() {
        super.init(style: UITableView.Style.grouped)
    }

    override init(style: UITableView.Style) {
        super.init(style: style)

    }
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Text Size"

        self.view.backgroundColor = UIColor.tinylogLightGray
        self.tableView?.backgroundColor = UIColor.tinylogLightGray
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(
            name: Notification.Name(
                rawValue: TLINotifications.kTLIFontDidChangeNotification as String),
                object: nil)
    }
    // swiftlint:disable cyclomatic_complexity
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        cell.accessoryType = UITableViewCell.AccessoryType.none
        cell.selectionStyle = UITableViewCell.SelectionStyle.none

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Use System Size"
                cell.textLabel?.font = UIFont.tinylogFontOfSize(17.0)
                cell.textLabel?.textColor = UIColor.tinylogTextColor

                let switchMode: UISwitch = UISwitch(
                    frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 20.0))
                switchMode.addTarget(
                    self,
                    action: #selector(TLITextSizeViewController.toggleSystemFontSize(_:)),
                    for: UIControl.Event.valueChanged)
                switchMode.onTintColor = UIColor.tinylogMainColor
                cell.accessoryView = switchMode
                cell.accessoryType = UITableViewCell.AccessoryType.none
                
                let userDefaults = Environment.current.userDefaults
                let useSystemFontSize = userDefaults.bool(forKey: TLIUserDefaults.kSystemFontSize)
                
                if useSystemFontSize {
                    switchMode.setOn(true, animated: false)
                } else {
                    switchMode.setOn(false, animated: false)
                }

            } else if indexPath.row == 1 {
                
                let userDefaults = Environment.current.userDefaults
                let size = userDefaults.double(forKey: TLIUserDefaults.kFontSize)

                var defaultValue: Int = 0
                for (index, number) in numbers.enumerated() {
                    if Int(size) == number {
                        defaultValue = index
                        break
                    }
                }

                let stepSlider: StepSliderControl = StepSliderControl(
                    frame: CGRect(
                        x: 10.0,
                        y: 0.0,
                        width: self.view.frame.size.width - 20.0,
                        height: 44.0))
                stepSlider.customizeForNumber(ofSteps: 8)
                stepSlider.minimumValue = 0
                stepSlider.maximumValue = Float(numbers.count - 1)
                stepSlider.value = Float(defaultValue)
                stepSlider.isContinuous = true
                stepSlider.addTarget(
                    self,
                    action: #selector(TLITextSizeViewController.sliderValue(_:)),
                    for: UIControl.Event.valueChanged)
                cell.contentView.addSubview(stepSlider)
                
                let useSystemFontSize = userDefaults.bool(forKey: TLIUserDefaults.kSystemFontSize)
                
                if useSystemFontSize {
                    stepSlider.alpha = 0.5
                    stepSlider.isUserInteractionEnabled = false
                } else {
                    stepSlider.alpha = 1.0
                    stepSlider.isUserInteractionEnabled = true
                }
            }
        }
    }

    @objc func sliderValue(_ sender: UISlider!) {
        let slider: UISlider = sender as UISlider
        let number = numbers[Int(slider.value)]
        Environment.current.userDefaults.set(Float(number), forKey: TLIUserDefaults.kFontSize)
    }

    // MARK: Actions

    @objc func toggleSystemFontSize(_ sender: UISwitch) {
        let mode: UISwitch = sender as UISwitch
        let value: NSString = mode.isOn == true ? "on" : "off"
        
        Environment.current.userDefaults.set(mode.isOn, forKey: TLIUserDefaults.kSystemFontSize)

        let indexPath = IndexPath(row: 1, section: 0)
        let cell = self.tableView.cellForRow(at: indexPath)

        if value == "on" {
            cell?.alpha = 0.5
            cell?.isUserInteractionEnabled = false
        } else if value == "off" {
            cell?.alpha = 1.0
            cell?.isUserInteractionEnabled = true
        }

        NotificationCenter.default.post(
            name: Notification.Name(
                rawValue: TLINotifications.kTLIFontDidChangeNotification as String),
                object: nil)

        self.tableView.reloadData()
    }

    func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(
            style: UITableViewCell.CellStyle.value1,
            reuseIdentifier: textSizeCellIdentifier)
        configureCell(cell, indexPath: indexPath)
        return cell
    }
}
