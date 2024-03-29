//
//  AddListButton.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

final class AddListButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {

        let origImage = UIImage(named: "plus")
        let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        // btn.setImage(tintedImage, for: .normal)
        tintColor = UIColor.tinylogMainColor

        self.setBackgroundImage(tintedImage, for: UIControl.State())
        self.setBackgroundImage(tintedImage, for: UIControl.State.highlighted)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let area: CGRect = self.bounds.insetBy(dx: -20, dy: -20)
        return area.contains(point)
    }
}
