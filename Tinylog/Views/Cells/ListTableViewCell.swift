//
//  ListTableViewCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class ListTableViewCell: GenericTableViewCell {

    let kRadius: CGFloat = 30.0
    var didSetupConstraints = false
    let listLabel: TTTAttributedLabel = TTTAttributedLabel.newAutoLayout()
    let totalTasksLabel: TTTAttributedLabel = TTTAttributedLabel.newAutoLayout()

    var currentList: TLIList? {
        didSet {
            updateFonts()
            if let currentList = currentList,
                let total = currentList.total as? Int,
                let color = currentList.color {
                listLabel.text = currentList.title
                totalTasksLabel.text = String(total)
                totalTasksLabel.layer.borderColor = UIColor(rgba: color).cgColor
                totalTasksLabel.textColor = UIColor(rgba: color)
            }
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
        willSet {
            if let list = newValue, let color = list.color {
              totalTasksLabel.textColor = UIColor(rgba: color)
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
        contentView.addSubview(listLabel)

        totalTasksLabel.layer.cornerRadius = kRadius / 2.0
        totalTasksLabel.layer.borderColor = UIColor.lightGray.cgColor
        totalTasksLabel.layer.borderWidth = 1.0
        totalTasksLabel.textAlignment = NSTextAlignment.center
        totalTasksLabel.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight]
        totalTasksLabel.clipsToBounds = true
        contentView.addSubview(totalTasksLabel)

        let selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView.backgroundColor = UIColor.tinylogLighterGray
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

    override func updateFonts() {
        super.updateFonts()

        listLabel.font = tinylogFont
        totalTasksLabel.font = tinylogFont
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()

        listLabel.preferredMaxLayoutWidth = listLabel.frame.width
    }
}
