//
//  TLIHelpTableViewCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import SGBackgroundView

class TLIHelpTableViewCell: TLITableViewCell {

    var didSetupConstraints = false
    var bgView: SGBackgroundView?
    let helpLabel: TTTAttributedLabel = TTTAttributedLabel.newAutoLayout()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // swiftlint:disable force_unwrapping
        bgView = SGBackgroundView(frame: CGRect.zero)
        bgView?.bgColor = UIColor.tinylogLightGray
        bgView?.lineColor = UIColor(red: 213.0 / 255.0, green: 213.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0)
        bgView?.xPosLine = 16.0
        self.backgroundView = bgView!

        helpLabel.lineBreakMode = .byTruncatingTail
        helpLabel.numberOfLines = 0
        helpLabel.textAlignment = .left
        helpLabel.textColor = UIColor.tinylogTextColor
        self.contentView.addSubview(helpLabel)

        let selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView.backgroundColor = UIColor(
            red: 237.0 / 255.0,
            green: 237.0 / 255.0,
            blue: 237.0 / 255.0,
            alpha: 1.0)
        selectedBackgroundView.contentMode = UIViewContentMode.redraw
        self.selectedBackgroundView = selectedBackgroundView

        updateFonts()

        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
    }

    override func updateConstraints() {
        if !didSetupConstraints {

            helpLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20.0)
            helpLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16.0)
            helpLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16.0)
            helpLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20.0)

            didSetupConstraints = true
        }
        super.updateConstraints()
    }
    // swiftlint:disable cyclomatic_complexity
    override func updateFonts() {
        super.updateFonts()

        let userDefaults: UserDefaults = UserDefaults.standard
        if let useSystemFontSize: String = userDefaults.object(forKey: "kSystemFontSize") as? String {

            if useSystemFontSize == "on" {
                if TLISettingsFontPickerViewController.selectedKey() == "Avenir" {
                    helpLabel.font = UIFont.preferredAvenirFontForTextStyle(
                        UIFontTextStyle.body.rawValue as NSString)
                } else if TLISettingsFontPickerViewController.selectedKey() == "HelveticaNeue" {
                    helpLabel.font = UIFont.preferredHelveticaNeueFontForTextStyle(
                        UIFontTextStyle.body.rawValue as NSString)
                } else if TLISettingsFontPickerViewController.selectedKey() == "Courier" {
                    helpLabel.font = UIFont.preferredCourierFontForTextStyle(
                        UIFontTextStyle.body.rawValue as NSString)
                } else if TLISettingsFontPickerViewController.selectedKey() == "Georgia" {
                    helpLabel.font = UIFont.preferredGeorgiaFontForTextStyle(
                        UIFontTextStyle.body.rawValue as NSString)
                } else if TLISettingsFontPickerViewController.selectedKey() == "Menlo" {
                    helpLabel.font = UIFont.preferredMenloFontForTextStyle(
                        UIFontTextStyle.body.rawValue as NSString)
                } else if TLISettingsFontPickerViewController.selectedKey() == "TimesNewRoman" {
                    helpLabel.font = UIFont.preferredTimesNewRomanFontForTextStyle(
                        UIFontTextStyle.body.rawValue as NSString)
                } else if TLISettingsFontPickerViewController.selectedKey() == "Palatino" {
                    helpLabel.font = UIFont.preferredPalatinoFontForTextStyle(
                        UIFontTextStyle.body.rawValue as NSString)
                } else if TLISettingsFontPickerViewController.selectedKey() == "Iowan" {
                    helpLabel.font = UIFont.preferredIowanFontForTextStyle(
                        UIFontTextStyle.body.rawValue as NSString)
                } else if TLISettingsFontPickerViewController.selectedKey() == "SanFrancisco" {
                    helpLabel.font = UIFont.preferredSFFontForTextStyle(
                        UIFontTextStyle.body.rawValue as NSString)
                }
            } else {
                let fontSize: Float = userDefaults.float(forKey: "kFontSize")
                helpLabel.font = UIFont.tinylogFontOfSize(CGFloat(fontSize))
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGSize = self.contentView.bounds.size

        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()

        helpLabel.preferredMaxLayoutWidth = helpLabel.frame.width

        if self.isEditing {
            bgView?.width = size.width + 78.0
            bgView?.height = size.height
        } else {
            bgView?.width = size.width
            bgView?.height = size.height
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
