//
//  ListsFooterView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class ListsFooterView: UIView {

    let footerView: UIView = UIView.newAutoLayout()
    let footerHeight: CGFloat = 60

    var infoLabel: TTTAttributedLabel = {
        let infoLabel = TTTAttributedLabel.newAutoLayout()
        infoLabel.font = UIFont.regularFontWithSize(14.0)
        infoLabel.textColor = UIColor.tinylogTextColor
        infoLabel.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        infoLabel.text = ""
        return infoLabel
    }()

    var borderLineView: UIView = {
        let borderLineView = UIView.newAutoLayout()
        borderLineView.backgroundColor = UIColor(named: "tableViewSeparator")
        return borderLineView
    }()

    var didSetupContraints = false

    lazy var addListButton: AddListButton = {
        let addListButton = AddListButton.newAutoLayout()
        addListButton.accessibilityIdentifier = "addListButton"
        return addListButton
    }()

    lazy var archiveButton: ArchiveButton = {
        let archiveButton = ArchiveButton.newAutoLayout()
        return archiveButton
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.tinylogLighterGray

        footerView.backgroundColor = UIColor.tinylogLighterGray
        addSubview(footerView)

        addSubview(borderLineView)
        addSubview(infoLabel)
        addSubview(addListButton)
        addSubview(archiveButton)

        updateInfoLabel("")

        setNeedsUpdateConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateInfoLabel(_ str: String) {
        infoLabel.text = str
        setNeedsUpdateConstraints()
    }

    override func updateConstraints() {

        let padding: CGFloat = 20.0

        if !didSetupContraints {

            footerView.autoMatch(.width, to: .width, of: self)
            footerView.autoSetDimension(.height, toSize: footerHeight)
            footerView.autoPinEdge(toSuperviewEdge: .top)

            borderLineView.autoMatch(.width, to: .width, of: self)
            borderLineView.autoSetDimension(.height, toSize: 0.5)
            borderLineView.autoPinEdge(toSuperviewEdge: .top)

            addListButton.autoSetDimensions(to: CGSize(width: 28.0, height: 28.0))
            addListButton.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
            addListButton.autoPinEdge(toSuperviewEdge: .left, withInset: padding)

            archiveButton.autoSetDimensions(to: CGSize(width: 28.0, height: 26.0))
            archiveButton.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
            archiveButton.autoPinEdge(toSuperviewEdge: .right, withInset: padding)

            infoLabel.autoAlignAxis(.horizontal, toSameAxisOf: footerView, withOffset: -5.0)
            infoLabel.autoAlignAxis(.vertical, toSameAxisOf: footerView)

            didSetupContraints = true
        }
        super.updateConstraints()
    }
}
