//
//  ListsFooterView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import SnapKit

final class ListsFooterView: UIView {

    private let footerView: UIView = UIView()
    let footerHeight: CGFloat = 60

    weak var delegate: ListsFooterViewDelegate?

    private var infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.font = UIFont.regularFontWithSize(14.0)
        infoLabel.textColor = UIColor.tinylogTextColor
        infoLabel.textAlignment = NSTextAlignment.center
        infoLabel.text = ""
        return infoLabel
    }()

    private var borderLineView: UIView = {
        let borderLineView = UIView()
        borderLineView.backgroundColor = UIColor(named: "tableViewSeparator")
        return borderLineView
    }()

    private var addListButton: AddListButton = {
        let addListButton = AddListButton()
        addListButton.accessibilityIdentifier = "addListButton"
        return addListButton
    }()

    private var archiveButton: ArchiveButton = {
        return ArchiveButton()
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor(named: "mainColor")

        footerView.backgroundColor = UIColor.white
        addSubview(footerView)

        addSubview(borderLineView)
        addSubview(infoLabel)
        addSubview(addListButton)
        addSubview(archiveButton)

        updateInfoLabel("")

        footerView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.height.equalTo(footerHeight)
        }

        borderLineView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(0.5)
        }

        addListButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 28.0, height: 28.0))
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

        addListButton.addTarget(self,
                                action: #selector(addNewList(_:)),
                                for: .touchDown)

        archiveButton.addTarget(self,
                                action: #selector(displayArchive(_:)),
                                for: .touchDown)

        setNeedsUpdateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func updateInfoLabel(_ str: String) {
        infoLabel.text = str
        setNeedsUpdateConstraints()
    }

    // MARK: - Actions

    @objc func addNewList(_ sender: AddListButton) {
        delegate?.listsFooterViewAddNewList(self)
    }

    @objc func displayArchive(_ button: ArchiveButton) {
        delegate?.listsFooterViewDisplayArchives(self)
    }
}
