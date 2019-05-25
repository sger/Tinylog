//
//  TasksFooterView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class TasksFooterView: UIView {

    var borderLineView: UIView = {
        let borderLineView = UIView()
        borderLineView.backgroundColor = UIColor(
            red: 213.0 / 255.0,
            green: 213.0 / 255.0,
            blue: 213.0 / 255.0,
            alpha: 1.0)
        return borderLineView
    }()

    let footerView: UIView = UIView()

    var infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.font = UIFont.regularFontWithSize(14.0)
        infoLabel.textColor = UIColor.tinylogTextColor
        //infoLabel.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        infoLabel.text = ""
        return infoLabel
    }()

    var currentText: String?
    var didSetupContraints = false

    var exportTasksButton: ExportTasksButton = {
        let exportTasksButton = ExportTasksButton()
        return exportTasksButton
    }()

    var archiveButton: ArchiveButton = {
        let archiveButton = ArchiveButton()
        return archiveButton
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        footerView.backgroundColor = UIColor.tinylogLighterGray
        addSubview(footerView)

        addSubview(borderLineView)
        addSubview(infoLabel)

        addSubview(exportTasksButton)
        addSubview(archiveButton)

        updateInfoLabel("")

        footerView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.height.equalTo(60.0)
        }

        borderLineView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(0.5)
        }

        exportTasksButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 21.0, height: 28.0))
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(20.0)
        }

        archiveButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 28.0, height: 28.0))
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(-20.0)
        }

        infoLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }

        setNeedsUpdateConstraints()
    }

    func updateInfoLabel(_ str: String) {
        currentText = str
        infoLabel.text = str
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
