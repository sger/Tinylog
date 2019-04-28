//
//  HelpTableViewCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import SGBackgroundView

class HelpTableViewCell: GenericTableViewCell {

    var didSetupConstraints = false
    var bgView: SGBackgroundView?
    let helpLabel: TTTAttributedLabel = TTTAttributedLabel.newAutoLayout()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        selectedBackgroundView.contentMode = UIView.ContentMode.redraw
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
    
    override func updateFonts() {
        super.updateFonts()

        helpLabel.font = tinylogFont
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
