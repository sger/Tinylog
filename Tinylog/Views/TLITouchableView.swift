//
//  TLITouchableView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLITouchableView: UIView {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for item in self.subviews {
            let view: UIView = item
            if view.isHidden && view.isUserInteractionEnabled && view.point(inside: point, with: event) {
                return true
            }
        }
        return false
    }
}
