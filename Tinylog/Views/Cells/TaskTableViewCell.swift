//
//  TaskTableViewCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import Nantes

final class TaskTableViewCell: GenericTableViewCell {

    private let kLabelHorizontalInsets: CGFloat = 60.0
    private let kLabelVerticalInsets: CGFloat = 10.0
    private var checkMarkIcon: UIImageView?

    let taskLabel: NantesLabel = NantesLabel(frame: .zero)
    let checkBoxButton: CheckBoxButton = CheckBoxButton()
    var managedObjectContext: NSManagedObjectContext!

    var task: TLITask? {
        didSet {
            guard let task = task,
                  let list = task.list,
                  let color = list.color else {
                return
            }

            let numberOfTasks = TLITask.numberOfTasks(with: managedObjectContext,
                                                      list: list)
            let numberOfCompletedTasks = TLITask.numberOfCompletedTasks(with: managedObjectContext,
                                                                        list: list)
            let totalTasks = numberOfTasks - numberOfCompletedTasks

            list.total = totalTasks as NSNumber

            checkBoxButton.circleView?.layer.borderColor = UIColor(rgba: color).cgColor
            checkBoxButton.checkMarkIcon?.image = checkBoxButton.checkMarkIcon?.image?.imageWithColor(
                UIColor(rgba: color))

            updateFonts()

            taskLabel.activeLinkAttributes = [.foregroundColor: UIColor(rgba: color)]

            if let boolValue = task.completed?.boolValue, boolValue {
                checkBoxButton.checkMarkIcon?.isHidden = false
                checkBoxButton.alpha = 0.5
                taskLabel.alpha = 0.5
                taskLabel.linkAttributes = [.foregroundColor: UIColor.lightGray]
            } else {
                checkBoxButton.checkMarkIcon?.isHidden = true
                checkBoxButton.alpha = 1.0
                taskLabel.alpha = 1.0
                taskLabel.linkAttributes = [.foregroundColor: UIColor(rgba: color)]
            }

            taskLabel.text = task.displayLongText

            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = UIColor(named: "mainColor")
        selectionStyle = .none

        taskLabel.lineBreakMode = .byTruncatingTail
        taskLabel.numberOfLines = 0
        taskLabel.textAlignment = .left
        taskLabel.textColor = UIColor(named: "textColor")
        contentView.addSubview(taskLabel)

        checkBoxButton.tableViewCell = self
        contentView.addSubview(checkBoxButton)

        taskLabel.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().inset(20.0)
            maker.leading.equalToSuperview().inset(22.0)
            maker.trailing.equalToSuperview().inset(50.0)
            maker.bottom.equalToSuperview().inset(20.0).priority(999)
        }

        checkBoxButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 30.0, height: 30.0))
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
        taskLabel.font = tinylogFont
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        taskLabel.preferredMaxLayoutWidth = taskLabel.frame.width
    }
}
