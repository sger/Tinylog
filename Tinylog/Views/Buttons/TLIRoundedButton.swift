//
//  TLIRoundedButton.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLIRoundedButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        self.titleLabel?.font = UIFont.mediumFontWithSize(17.0)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let area: CGRect = self.bounds.insetBy(dx: -20, dy: -20)
        return area.contains(point)
    }
}
