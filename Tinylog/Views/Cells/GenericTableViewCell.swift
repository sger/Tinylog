//
//  GenericTableViewCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class GenericTableViewCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 51.0
    
    var tinylogFont: UIFont? {
        let userDefaults = Environment.current.userDefaults
        let useSystemFontSize = userDefaults.bool(forKey: EnvUserDefaults.systemFontSize)
        
        if useSystemFontSize {
            
            if SettingsFontPickerViewController.selectedKey() == "Avenir" {
                return UIFont.preferredAvenirFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            } else if SettingsFontPickerViewController.selectedKey() == "HelveticaNeue" {
                return UIFont.preferredHelveticaNeueFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            } else if SettingsFontPickerViewController.selectedKey() == "Courier" {
                return UIFont.preferredCourierFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            } else if SettingsFontPickerViewController.selectedKey() == "Georgia" {
                return UIFont.preferredGeorgiaFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            } else if SettingsFontPickerViewController.selectedKey() == "Menlo" {
                return UIFont.preferredMenloFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            } else if SettingsFontPickerViewController.selectedKey() == "TimesNewRoman" {
                return UIFont.preferredTimesNewRomanFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            } else if SettingsFontPickerViewController.selectedKey() == "Palatino" {
                return UIFont.preferredPalatinoFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            } else if SettingsFontPickerViewController.selectedKey() == "Iowan" {
                return UIFont.preferredIowanFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            } else if SettingsFontPickerViewController.selectedKey() == "SanFrancisco" {
                return UIFont.preferredSFFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            }
        }
        
        let fontSize = userDefaults.double(forKey: EnvUserDefaults.fontSize)
        return UIFont.tinylogFontOfSize(CGFloat(fontSize))
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        updateFonts()
        contentView.clipsToBounds = true

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(GenericTableViewCell.updateFonts),
                                               name: NSNotification.Name(rawValue: Notifications.fontDidChangeNotification),
                                               object: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if !selected {
            self.textLabel!.backgroundColor = UIColor.clear
        }
    }

    @objc func updateFonts() {}
}
