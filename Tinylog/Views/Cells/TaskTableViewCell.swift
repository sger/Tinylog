//
//  TaskTableViewCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_unwrapping
import UIKit
import TTTAttributedLabel

class TaskTableViewCell: GenericTableViewCell {

    let kLabelHorizontalInsets: CGFloat = 60.0
    let kLabelVerticalInsets: CGFloat = 10.0
    let taskLabel: TTTAttributedLabel = TTTAttributedLabel(frame: CGRect.zero)

    let checkBoxButton: CheckBoxButton = CheckBoxButton()
    var checkMarkIcon: UIImageView?
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

            taskLabel.activeLinkAttributes = [
                kCTForegroundColorAttributeName as AnyHashable: UIColor(
                    rgba: currentTask!.list!.color!)]

            if let boolValue = currentTask?.completed?.boolValue {
                if boolValue {
                    checkBoxButton.checkMarkIcon!.isHidden = false
                    checkBoxButton.alpha = 0.5
                    taskLabel.alpha = 0.5
                    taskLabel.linkAttributes = [
                        kCTForegroundColorAttributeName as AnyHashable: UIColor.lightGray]
                } else {
                    checkBoxButton.checkMarkIcon!.isHidden = true
                    checkBoxButton.alpha = 1.0
                    taskLabel.alpha = 1.0
                    taskLabel.linkAttributes = [
                        kCTForegroundColorAttributeName as AnyHashable: UIColor(
                            rgba: currentTask!.list!.color!)]
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
            maker.bottom.equalToSuperview().inset(20.0)
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
        taskLabel.setText(currentTask?.displayLongText) {
            (mutableAttributedString) -> NSMutableAttributedString? in
            return mutableAttributedString
        }
        if let textTaskLabel = taskLabel.text, let total = textTaskLabel as? NSString {
            let words: [String] = total.components(separatedBy: " ")
            for word in words {
                let character = word as NSString
                if character.hasPrefix("http://") || character.hasPrefix("https://") {
                    // swiftlint:disable legacy_constructor
                    let value: NSString = character.substring(
                        with: NSMakeRange(0, character.length)) as NSString
                    let range: NSRange = total.range(of: character as String)
                    let url: URL = URL(string: NSString(format: "%@", value) as String)!
                    taskLabel.addLink(to: url, with: range)
                }
            }
        }
    }
}
