//
//  ListsFooterView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import SnapKit

class ListsFooterView: UIView {

    let footerView: UIView = UIView.newAutoLayout()
    let footerHeight: CGFloat = 60

    var infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.font = UIFont.regularFontWithSize(14.0)
        infoLabel.textColor = UIColor.tinylogTextColor
        infoLabel.textAlignment = NSTextAlignment.center
        infoLabel.text = ""
        return infoLabel
    }()

    var borderLineView: UIView = {
        let borderLineView = UIView()
        borderLineView.backgroundColor = UIColor(named: "tableViewSeparator")
        return borderLineView
    }()

    var didSetupContraints = false

    var addListButton: AddListButton = {
        let addListButton = AddListButton()
        addListButton.accessibilityIdentifier = "addListButton"
        return addListButton
    }()

    var archiveButton: ArchiveButton = {
        let archiveButton = ArchiveButton()
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

        setNeedsUpdateConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateInfoLabel(_ str: String) {
        infoLabel.text = str
        setNeedsUpdateConstraints()
    }
}
