//
//  TLIListsFooterView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_unwrapping
import UIKit
import TTTAttributedLabel

class TLIListsFooterView: UIView {

    var infoLabel: TTTAttributedLabel? = {
        let infoLabel = TTTAttributedLabel.newAutoLayout()
        infoLabel.font = UIFont.regularFontWithSize(14.0)
        infoLabel.textColor = UIColor.tinylogTextColor
        infoLabel.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        infoLabel.text = ""
        return infoLabel
    }()

    var borderLineView: UIView = {
        let borderLineView = UIView.newAutoLayout()
        borderLineView.backgroundColor = UIColor(
            red: 213.0 / 255.0,
            green: 213.0 / 255.0,
            blue: 213.0 / 255.0,
            alpha: 1.0)
        return borderLineView
    }()

    var currentText: String?
    let footerView: UIView = UIView.newAutoLayout()
    var didSetupContraints = false

    lazy var addListButton: TLIAddListButton? = {
        let addListButton = TLIAddListButton.newAutoLayout()
        return addListButton
    }()

    lazy var archiveButton: TLIArchiveButton? = {
        let archiveButton = TLIArchiveButton.newAutoLayout()
        return archiveButton
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        footerView.backgroundColor = UIColor.tinylogLighterGray
        self.addSubview(footerView)

        self.addSubview(borderLineView)
        self.addSubview(infoLabel!)
        self.addSubview(addListButton!)
        self.addSubview(archiveButton!)

        updateInfoLabel("")

        setNeedsUpdateConstraints()
    }

    func updateInfoLabel(_ str: String) {
        currentText = str
        infoLabel?.text = str

        setNeedsUpdateConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        let smallPadding: CGFloat = 16.0

        if !didSetupContraints {

            footerView.autoMatch(.width, to: .width, of: self)
            footerView.autoSetDimension(.height, toSize: 51.0)
            footerView.autoPinEdge(toSuperviewEdge: .bottom)

            borderLineView.autoMatch(.width, to: .width, of: self)
            borderLineView.autoSetDimension(.height, toSize: 0.5)
            borderLineView.autoPinEdge(toSuperviewEdge: .top)

            addListButton?.autoSetDimensions(to: CGSize(width: 18.0, height: 18.0))
            addListButton?.autoAlignAxis(toSuperviewAxis: .horizontal)
            addListButton?.autoPinEdge(toSuperviewEdge: .left, withInset: smallPadding)

            archiveButton?.autoSetDimensions(to: CGSize(width: 28.0, height: 26.0))
            archiveButton?.autoAlignAxis(toSuperviewAxis: .horizontal)
            archiveButton?.autoPinEdge(toSuperviewEdge: .right, withInset: smallPadding)

            infoLabel?.autoCenterInSuperview()

            didSetupContraints = true
        }
        super.updateConstraints()
    }
}
