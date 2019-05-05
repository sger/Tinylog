//
//  SettingsFontPickerViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_cast
// swiftlint:disable force_unwrapping
import UIKit

class SettingsFontPickerViewController: UITableViewController {

    var currentIndexPath: NSIndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Font"
        self.view.backgroundColor = UIColor.tinylogLightGray
        self.tableView?.backgroundColor = UIColor.tinylogLightGray
        let selectedKey: NSString? = SettingsFontPickerViewController.selectedKey()!

        if selectedKey != nil {

            let row = self.keys()?.index(of: selectedKey!)
            self.currentIndexPath = NSIndexPath(row: row!, section: 0)
            self.tableView.reloadData()
            self.tableView.scrollToRow(
                at: self.currentIndexPath! as IndexPath,
                at: UITableView.ScrollPosition.middle,
                animated: false)
        }
    }

    struct FontKeys {
        static var kTLIFontDefaultsKey: NSString = "TLIFontDefaults"
        static var kTLIFontSFDefaultsKey: NSString = "SanFrancisco"
        static var kTLIFontHelveticaNeueDefaultsKey: NSString = "HelveticaNeue"
        static var kTLIFontAvenirDefaultsKey: NSString = "Avenir"
        static var kTLIFontHoeflerDefaultsKey: NSString = "Hoefler"
        static var kTLIFontCourierDefaultsKey: NSString = "Courier"
        static var kTLIFontGeorgiaDefaultsKey: NSString = "Georgia"
        static var kTLIFontMenloDefaultsKey: NSString = "Menlo"
        static var kTLIFontTimesNewRomanDefaultsKey: NSString = "TimesNewRoman"
        static var kTLIFontPalatinoDefaultsKey: NSString = "Palatino"
        static var kTLIFontIowanDefaultsKey: NSString = "Iowan"
    }

    // make large, medium, small
    static func fontSizeAdjustment() -> CGFloat {
        return 0.0
    }

    static func defaultsKey() -> NSString? {
        return FontKeys.kTLIFontDefaultsKey
    }

    static func valueMap() -> NSDictionary? {
        var map: NSDictionary?

        let _onceToken = NSUUID().uuidString

        DispatchQueue.once(token: _onceToken) {
            if #available(iOS 9, *) {
                map = NSDictionary(objects: [
                    "San Francisco",
                    "Helvetica Neue",
                    "Avenir",
                    "Hoefler",
                    "Courier",
                    "Georgia",
                    "Menlo",
                    "Times New Roman",
                    "Palatino",
                    "Iowan Old Style"], forKeys: [
                        FontKeys.kTLIFontSFDefaultsKey,
                        FontKeys.kTLIFontHelveticaNeueDefaultsKey,
                        FontKeys.kTLIFontAvenirDefaultsKey,
                        FontKeys.kTLIFontHoeflerDefaultsKey,
                        FontKeys.kTLIFontCourierDefaultsKey,
                        FontKeys.kTLIFontGeorgiaDefaultsKey,
                        FontKeys.kTLIFontMenloDefaultsKey,
                        FontKeys.kTLIFontTimesNewRomanDefaultsKey,
                        FontKeys.kTLIFontPalatinoDefaultsKey,
                        FontKeys.kTLIFontIowanDefaultsKey])
            } else {
                map = NSDictionary(objects: [
                    "Helvetica Neue",
                    "Avenir",
                    "Hoefler",
                    "Courier",
                    "Georgia",
                    "Menlo",
                    "Times New Roman",
                    "Palatino",
                    "Iowan Old Style"], forKeys: [
                        FontKeys.kTLIFontHelveticaNeueDefaultsKey,
                        FontKeys.kTLIFontAvenirDefaultsKey,
                        FontKeys.kTLIFontHoeflerDefaultsKey,
                        FontKeys.kTLIFontCourierDefaultsKey,
                        FontKeys.kTLIFontGeorgiaDefaultsKey,
                        FontKeys.kTLIFontMenloDefaultsKey,
                        FontKeys.kTLIFontTimesNewRomanDefaultsKey,
                        FontKeys.kTLIFontPalatinoDefaultsKey,
                        FontKeys.kTLIFontIowanDefaultsKey])
            }

        }

        return map
    }

    func keys() -> NSArray? {

        if #available(iOS 9, *) {
            let arr = NSArray(objects:
                FontKeys.kTLIFontSFDefaultsKey,
                FontKeys.kTLIFontHelveticaNeueDefaultsKey,
                FontKeys.kTLIFontAvenirDefaultsKey,
                FontKeys.kTLIFontHoeflerDefaultsKey,
                FontKeys.kTLIFontCourierDefaultsKey,
                FontKeys.kTLIFontGeorgiaDefaultsKey,
                FontKeys.kTLIFontMenloDefaultsKey,
                FontKeys.kTLIFontTimesNewRomanDefaultsKey,
                FontKeys.kTLIFontPalatinoDefaultsKey,
                FontKeys.kTLIFontIowanDefaultsKey)
            let sortedArray = arr.sortedArray(using: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
            return sortedArray as NSArray
        } else {
            let arr = NSArray(objects:
                FontKeys.kTLIFontHelveticaNeueDefaultsKey,
                FontKeys.kTLIFontAvenirDefaultsKey,
                FontKeys.kTLIFontHoeflerDefaultsKey,
                FontKeys.kTLIFontCourierDefaultsKey,
                FontKeys.kTLIFontGeorgiaDefaultsKey,
                FontKeys.kTLIFontMenloDefaultsKey,
                FontKeys.kTLIFontTimesNewRomanDefaultsKey,
                FontKeys.kTLIFontPalatinoDefaultsKey,
                FontKeys.kTLIFontIowanDefaultsKey)
            let sortedArray = arr.sortedArray(using: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
            return sortedArray as NSArray
        }
    }

    static func selectedKey() -> NSString? {
        return Environment.current.userDefaults.string(forKey: defaultsKey()! as String) as NSString?
    }

    static func setSelectedKey(key: NSString) {
        Environment.current.userDefaults.set(key, forKey: defaultsKey()! as String)
    }

    func cellTextForKey(key: AnyObject) -> String? {
        guard let key = key as? String else {
            fatalError()
        }
        return SettingsFontPickerViewController.textForKey(key: key)
    }

    func cellImageForKey(key: AnyObject) -> UIImage? {
        return nil
    }

    static func textForKey(key: String) -> String? {
        return valueMap()?.object(forKey: key) as? String
    }

    static func textForSelectedKey() -> String? {
        return textForKey(key: selectedKey()! as String)!
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys()!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GroupedTableViewCell = GroupedTableViewCell(
            style: UITableViewCell.CellStyle.default,
            reuseIdentifier: "CellIdentifier")
        let key: NSString = self.keys()!.object(at: indexPath.row) as! NSString
        let selectedKey = SettingsFontPickerViewController.selectedKey()!
        cell.textLabel!.text = self.cellTextForKey(key: key) as String?
        cell.tintColor = UIColor.tinylogMainColor

        if key as NSString == selectedKey {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        cell.textLabel!.font = UIFont.tinylogFontOfSize(18.0, key: key)!
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(
            at: indexPath as IndexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        currentIndexPath = indexPath as NSIndexPath

        SettingsFontPickerViewController.setSelectedKey(
            key: self.keys()!.object(at: indexPath.row) as! NSString)
        self.navigationController?.popViewController(animated: true)

        NotificationCenter.default.post(
            name: NSNotification.Name(
                rawValue: Notifications.fontDidChangeNotification),
                object: nil)
    }
}
