//
//  TasksFooterView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_unwrapping
import UIKit
import TTTAttributedLabel

class TasksFooterView: UIView {

    var borderLineView: UIView = {
        let borderLineView = UIView.newAutoLayout()
        borderLineView.backgroundColor = UIColor(
            red: 213.0 / 255.0,
            green: 213.0 / 255.0,
            blue: 213.0 / 255.0,
            alpha: 1.0)
        return borderLineView
    }()

    let footerView: UIView = UIView.newAutoLayout()

    var infoLabel: TTTAttributedLabel? = {
        let infoLabel = TTTAttributedLabel.newAutoLayout()
        infoLabel.font = UIFont.regularFontWithSize(14.0)
        infoLabel.textColor = UIColor.tinylogTextColor
        infoLabel.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        infoLabel.text = ""
        return infoLabel
    }()

    var currentText: String?
    var didSetupContraints = false

    lazy var exportTasksButton: ExportTasksButton? = {
        let exportTasksButton = ExportTasksButton.newAutoLayout()
        return exportTasksButton
    }()

    lazy var archiveButton: ArchiveButton? = {
        let archiveButton = ArchiveButton.newAutoLayout()
        return archiveButton
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        footerView.backgroundColor = UIColor.tinylogLighterGray
        addSubview(footerView)

        addSubview(borderLineView)
        addSubview(infoLabel!)

        addSubview(exportTasksButton!)
        addSubview(archiveButton!)

        updateInfoLabel("")

        setNeedsUpdateConstraints()
    }

    func updateInfoLabel(_ str: String) {
        currentText = str
        infoLabel?.text = str
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        let smallPadding: CGFloat = 16.0

        if !didSetupContraints {

            footerView.autoMatch(.width, to: .width, of: self)
            footerView.autoSetDimension(.height, toSize: 60.0)
            footerView.autoPinEdge(toSuperviewEdge: .bottom)

            borderLineView.autoMatch(.width, to: .width, of: self)
            borderLineView.autoSetDimension(.height, toSize: 0.5)
            borderLineView.autoPinEdge(toSuperviewEdge: .top)

            exportTasksButton?.autoSetDimensions(to: CGSize(width: 21.0, height: 28.0))
            exportTasksButton?.autoAlignAxis(toSuperviewAxis: .horizontal)
            exportTasksButton?.autoPinEdge(toSuperviewEdge: .left, withInset: smallPadding)

            archiveButton?.autoSetDimensions(to: CGSize(width: 28.0, height: 26.0))
            archiveButton?.autoAlignAxis(toSuperviewAxis: .horizontal)
            archiveButton?.autoPinEdge(toSuperviewEdge: .right, withInset: smallPadding)

            infoLabel?.autoCenterInSuperview()

            didSetupContraints = true
        }
        super.updateConstraints()
    }
}
