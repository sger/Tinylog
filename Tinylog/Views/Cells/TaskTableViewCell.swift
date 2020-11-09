//
//  TaskTableViewCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import Nantes

protocol TaskTableViewCellDelegate: AnyObject {
    func taskTableViewCellDidTapCheckBoxButton(_ cell: TaskTableViewCell,
                                               list: TLIList)
}

final class TaskTableViewCell: GenericTableViewCell {

    private let kLabelHorizontalInsets: CGFloat = 60.0
    private let kLabelVerticalInsets: CGFloat = 10.0
    private var checkMarkIcon: UIImageView?

    let taskLabel: NantesLabel = NantesLabel(frame: .zero)
    let checkBoxButton: CheckBoxButton = CheckBoxButton()
    var managedObjectContext: NSManagedObjectContext!
    weak var delegate: TaskTableViewCellDelegate?

    var task: TLITask? {
        didSet {
            guard let task = task,
                  let list = task.list,
                  let color = list.color else {
                return
            }

            let numberOfTasks = TLITask.numberOfUnarchivedTasks(with: managedObjectContext,
                                                      list: list)
            let numberOfCompletedTasks = TLITask.numberOfUnarchivedCompletedTasks(with: managedObjectContext,
                                                                        list: list)
            let totalTasks = numberOfTasks - numberOfCompletedTasks

            list.total = totalTasks as NSNumber

            checkBoxButton.circleView?.layer.borderColor = UIColor(rgba: color).cgColor
            checkBoxButton.checkMarkIcon?.image = checkBoxButton.checkMarkIcon?.image?.imageWithColor(
                UIColor(rgba: color))
            checkBoxButton.addTarget(self, action: #selector(toggleComplete(_:)),
                                     for: .touchUpInside)

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
        taskLabel.delegate = self
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

    @objc func toggleComplete(_ button: CheckBoxButton) {
        if task?.completed?.boolValue == true {
            task?.completed = NSNumber(value: false)
            task?.completedAt = nil
        } else {
            task?.completed = NSNumber(value: true)
            task?.completedAt = Date()
        }

        task?.updatedAt = Date()

        let animation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = NSNumber(value: 1.4)
        animation.toValue = NSNumber(value: 1.0)
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.3, 1, 1)
        button.layer.add(animation, forKey: "bounceAnimation")

        try? managedObjectContext.save()

        guard let list = task?.list else {
            return
        }

        delegate?.taskTableViewCellDidTapCheckBoxButton(self, list: list)
    }
}

extension TaskTableViewCell: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        UIApplication.shared.open(link,
                                  options: [:],
                                  completionHandler: nil)
    }
}
