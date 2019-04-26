//
//  TLIListTableViewCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class TLIListTableViewCell: TLITableViewCell {

    let kRadius: CGFloat = 30.0
    var didSetupConstraints = false
    let listLabel: TTTAttributedLabel = TTTAttributedLabel.newAutoLayout()
    let totalTasksLabel: TTTAttributedLabel = TTTAttributedLabel.newAutoLayout()
    var checkBoxButton: TLICheckBoxButton?

    var currentList: TLIList? {
        didSet {
            updateFonts()
            if let currentList = currentList,
                let total = currentList.total as? Int,
                let color = currentList.color {
                self.listLabel.text = currentList.title
                self.totalTasksLabel.text = String(total)
                totalTasksLabel.layer.borderColor = UIColor(rgba: color).cgColor
                self.totalTasksLabel.textColor = UIColor(rgba: color)
            }
            self.setNeedsUpdateConstraints()
            self.updateConstraintsIfNeeded()
        }
        willSet {
            if let list = newValue, let color = list.color {
              self.totalTasksLabel.textColor = UIColor(rgba: color)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.currentList = nil
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = UIColor.tinylogLightGray

        listLabel.lineBreakMode = .byTruncatingTail
        listLabel.numberOfLines = 0
        listLabel.textAlignment = .left
        listLabel.textColor = UIColor.tinylogTextColor
        self.contentView.addSubview(listLabel)

        totalTasksLabel.layer.cornerRadius = kRadius / 2.0
        totalTasksLabel.layer.borderColor = UIColor.lightGray.cgColor
        totalTasksLabel.layer.borderWidth = 1.0
        totalTasksLabel.textAlignment = NSTextAlignment.center
        totalTasksLabel.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight]
        totalTasksLabel.clipsToBounds = true
        self.contentView.addSubview(totalTasksLabel)

        let selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView.backgroundColor = UIColor(
            red: 244.0 / 255.0,
            green: 244.0 / 255.0,
            blue: 244.0 / 255.0,
            alpha: 1.0)
        selectedBackgroundView.contentMode = UIView.ContentMode.redraw
        self.selectedBackgroundView = selectedBackgroundView

        updateFonts()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        if !didSetupConstraints {

            listLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20.0)
            listLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16.0)
            listLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 50.0)
            listLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20.0)

            totalTasksLabel.autoSetDimensions(to: CGSize(width: kRadius, height: kRadius))
            totalTasksLabel.autoAlignAxis(.horizontal, toSameAxisOf: self.contentView, withOffset: 0.0)
            totalTasksLabel.autoPinEdge(.left, to: .right, of: listLabel, withOffset: 10.0)

            didSetupConstraints = true
        }
        super.updateConstraints()
    }
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable line_length
    override func updateFonts() {
        super.updateFonts()

        let userDefaults = Environment.current.userDefaults
        let useSystemFontSize = userDefaults.bool(forKey: TLIUserDefaults.kSystemFontSize)

        if useSystemFontSize {

            if TLISettingsFontPickerViewController.selectedKey() == "Avenir" {
                listLabel.font = UIFont.preferredAvenirFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
                totalTasksLabel.font = UIFont.preferredAvenirFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            } else if TLISettingsFontPickerViewController.selectedKey() == "HelveticaNeue" {
                listLabel.font = UIFont.preferredHelveticaNeueFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
                totalTasksLabel.font = UIFont.preferredHelveticaNeueFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            } else if TLISettingsFontPickerViewController.selectedKey() == "Courier" {
                listLabel.font = UIFont.preferredCourierFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
                totalTasksLabel.font = UIFont.preferredCourierFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            } else if TLISettingsFontPickerViewController.selectedKey() == "Georgia" {
                listLabel.font = UIFont.preferredGeorgiaFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
                totalTasksLabel.font = UIFont.preferredGeorgiaFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            } else if TLISettingsFontPickerViewController.selectedKey() == "Menlo" {
                listLabel.font = UIFont.preferredMenloFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
                totalTasksLabel.font = UIFont.preferredMenloFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            } else if TLISettingsFontPickerViewController.selectedKey() == "TimesNewRoman" {
                listLabel.font = UIFont.preferredTimesNewRomanFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
                totalTasksLabel.font = UIFont.preferredTimesNewRomanFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            } else if TLISettingsFontPickerViewController.selectedKey() == "Palatino" {
                listLabel.font = UIFont.preferredPalatinoFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
                totalTasksLabel.font = UIFont.preferredPalatinoFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            } else if TLISettingsFontPickerViewController.selectedKey() == "Iowan" {
                listLabel.font = UIFont.preferredIowanFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
                totalTasksLabel.font = UIFont.preferredIowanFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            } else if TLISettingsFontPickerViewController.selectedKey() == "SanFrancisco" {
                listLabel.font = UIFont.preferredSFFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
                totalTasksLabel.font = UIFont.preferredSFFontForTextStyle(UIFont.TextStyle.body.rawValue as NSString)
            }

        } else {
            let fontSize = userDefaults.double(forKey: TLIUserDefaults.kFontSize)
            listLabel.font = UIFont.tinylogFontOfSize(CGFloat(fontSize))
            totalTasksLabel.font = UIFont.tinylogFontOfSize(CGFloat(fontSize - 2))
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()

        listLabel.preferredMaxLayoutWidth = listLabel.frame.width
    }
}
