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

    let helpLabel = UILabel()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = UIColor(named: "mainColor")

        helpLabel.lineBreakMode = .byTruncatingTail
        helpLabel.numberOfLines = 0
        helpLabel.textAlignment = .left
        helpLabel.textColor = UIColor(named: "textColor")
        contentView.addSubview(helpLabel)

        helpLabel.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().inset(20.0)
            maker.leading.equalToSuperview().inset(16.0)
            maker.trailing.equalToSuperview().inset(10.0)
            maker.bottom.equalToSuperview().inset(20.0)
        }

        let selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView.backgroundColor = UIColor(named: "tableViewSelected")
        selectedBackgroundView.contentMode = UIView.ContentMode.redraw
        self.selectedBackgroundView = selectedBackgroundView

        updateFonts()

        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
