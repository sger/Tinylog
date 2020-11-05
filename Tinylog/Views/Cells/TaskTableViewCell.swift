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

    private let kLabelHorizontalInsets: CGFloat = 60.0
    private let kLabelVerticalInsets: CGFloat = 10.0
    private var checkMarkIcon: UIImageView?
    
    let taskLabel: NantesLabel = NantesLabel(frame: .zero)
    let checkBoxButton: CheckBoxButton = CheckBoxButton()
    var managedObjectContext: NSManagedObjectContext!

    var currentTask: TLITask? {
        didSet {

            // Fetch all objects from list

            let fetchRequestTotal: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Task")
            let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
            fetchRequestTotal.sortDescriptors = [positionDescriptor]
            fetchRequestTotal.predicate  = NSPredicate(
                format: "archivedAt = nil AND list = %@", currentTask!.list!)
            fetchRequestTotal.fetchBatchSize = 20

            do {
                let results: NSArray = try managedObjectContext.fetch(fetchRequestTotal) as NSArray

                let fetchRequestCompleted: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
                    entityName: "Task")
                fetchRequestCompleted.sortDescriptors = [positionDescriptor]
                fetchRequestCompleted.predicate  = NSPredicate(
                    format: "archivedAt = nil AND completed = %@ AND list = %@",
                    NSNumber(value: true as Bool), currentTask!.list!)
                fetchRequestCompleted.fetchBatchSize = 20
                let resultsCompleted: NSArray = try managedObjectContext.fetch(
                    fetchRequestCompleted) as NSArray

                let total: Int = results.count - resultsCompleted.count
                currentTask?.list!.total = total as NSNumber?

                checkBoxButton.circleView?.layer.borderColor = UIColor(
                    rgba: currentTask!.list!.color!).cgColor
                checkBoxButton.checkMarkIcon?.image = checkBoxButton.checkMarkIcon?.image?.imageWithColor(
                    UIColor(rgba: currentTask!.list!.color!))
            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }

            updateFonts()

            taskLabel.activeLinkAttributes = [NSAttributedString.Key.foregroundColor: UIColor(rgba: (currentTask?.list?.color)!)]

            if let boolValue = currentTask?.completed?.boolValue {
                if boolValue {
                    checkBoxButton.checkMarkIcon!.isHidden = false
                    checkBoxButton.alpha = 0.5
                    taskLabel.alpha = 0.5
                    taskLabel.linkAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
                } else {
                    checkBoxButton.checkMarkIcon!.isHidden = true
                    checkBoxButton.alpha = 1.0
                    taskLabel.alpha = 1.0
                    taskLabel.linkAttributes = [NSAttributedString.Key.foregroundColor: UIColor(rgba: (currentTask?.list?.color)!)]
                }
            }

            updateAttributedText()

            self.setNeedsUpdateConstraints()
            self.updateConstraintsIfNeeded()
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

        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()

        taskLabel.preferredMaxLayoutWidth = taskLabel.frame.width
    }

    func updateAttributedText() {
        taskLabel.text = currentTask?.displayLongText
    }
}
