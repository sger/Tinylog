//
//  ListTableViewCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

final class ListTableViewCell: GenericTableViewCell {

    static let cellIdentifier = "ListTableViewCell"

    let kRadius: CGFloat = 30.0
    let listLabel = UILabel()
    let totalTasksLabel = UILabel()

    var list: TLIList? {
        didSet {
            updateFonts()
            if let list = list,
                let total = list.total as? Int,
                let color = list.color {
                listLabel.text = list.title
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
        self.list = nil
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = UIColor.white

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

        listLabel.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().inset(20.0)
            maker.leading.equalToSuperview().inset(16.0)
            maker.trailing.equalToSuperview().inset(50.0)
            maker.bottom.equalToSuperview().inset(20.0)
        }

        totalTasksLabel.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: kRadius, height: kRadius))
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16.0)
        }

        updateFonts()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
