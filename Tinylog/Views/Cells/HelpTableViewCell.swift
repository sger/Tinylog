//
//  HelpTableViewCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import TTTAttributedLabel

final class HelpTableViewCell: GenericTableViewCell {

    var didSetupConstraints = false
    let helpLabel: TTTAttributedLabel = TTTAttributedLabel.newAutoLayout()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = UIColor.tinylogLightGray

        helpLabel.lineBreakMode = .byTruncatingTail
        helpLabel.numberOfLines = 0
        helpLabel.textAlignment = .left
        helpLabel.textColor = UIColor.tinylogTextColor
        contentView.addSubview(helpLabel)

        let selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView.backgroundColor = UIColor.tinylogLighterGray
        selectedBackgroundView.contentMode = UIView.ContentMode.redraw
        self.selectedBackgroundView = selectedBackgroundView

        updateFonts()

        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()

        helpLabel.preferredMaxLayoutWidth = helpLabel.frame.width
    }
}
