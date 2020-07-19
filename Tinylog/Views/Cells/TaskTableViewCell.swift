//
//  TaskTableViewCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_unwrapping
import UIKit
import Nantes

final class TaskTableViewCell: GenericTableViewCell {

    let kLabelHorizontalInsets: CGFloat = 60.0
    let kLabelVerticalInsets: CGFloat = 10.0
    let taskLabel: NantesLabel = NantesLabel(frame: CGRect.zero)

    let checkBoxButton: CheckBoxButton = CheckBoxButton()
    var checkMarkIcon: UIImageView?
    var managedObjectContext: NSManagedObjectContext!

    var task: TLITask? {
        didSet {
            guard let task = task,
                let list = task.list,
                let color = list.color else {
                return
            }
            
            // Fetch all objects from list

            let fetchRequestTotal: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Task")
            let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
            fetchRequestTotal.sortDescriptors = [positionDescriptor]
            fetchRequestTotal.predicate  = NSPredicate(
                format: "archivedAt = nil AND list = %@", list)
            fetchRequestTotal.fetchBatchSize = 20

            do {
                let results: NSArray = try managedObjectContext.fetch(fetchRequestTotal) as NSArray

                let fetchRequestCompleted: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
                    entityName: "Task")
                fetchRequestCompleted.sortDescriptors = [positionDescriptor]
                fetchRequestCompleted.predicate  = NSPredicate(
                    format: "archivedAt = nil AND completed = %@ AND list = %@",
                    NSNumber(value: true as Bool), list)
                fetchRequestCompleted.fetchBatchSize = 20
                let resultsCompleted: NSArray = try managedObjectContext.fetch(
                    fetchRequestCompleted) as NSArray

                let total: Int = results.count - resultsCompleted.count
                list.total = total as NSNumber?

                checkBoxButton.circleView?.layer.borderColor = UIColor(rgba: color).cgColor
                checkBoxButton.checkMarkIcon?.image = checkBoxButton.checkMarkIcon?.image?.imageWithColor(
                    UIColor(rgba: color))
            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }

            updateFonts()

            taskLabel.activeLinkAttributes = [NSAttributedString.Key.foregroundColor: UIColor(rgba: color)]

            if let boolValue = task.completed?.boolValue {
                if boolValue {
                    checkBoxButton.checkMarkIcon!.isHidden = false
                    checkBoxButton.alpha = 0.5
                    taskLabel.alpha = 0.5
                    taskLabel.linkAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
                } else {
                    checkBoxButton.checkMarkIcon!.isHidden = true
                    checkBoxButton.alpha = 1.0
                    taskLabel.alpha = 1.0
                    taskLabel.linkAttributes = [NSAttributedString.Key.foregroundColor: UIColor(rgba: color)]
                }
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
        taskLabel.delegate = self
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

extension TaskTableViewCell: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        UIApplication.shared.open(link,
                                  options: [:],
                                  completionHandler: nil)
    }
}
