//
//  TLICheckBoxButton.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_unwrapping
import UIKit

class CheckBoxButton: UIButton {

    var tableViewCell: UITableViewCell?
    var circleView: TouchableView?
    var checkMarkIcon: UIImageView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        circleView = TouchableView(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
        circleView?.layer.cornerRadius = 30.0 / 2
        circleView?.layer.borderColor = UIColor.tinylogMainColor.cgColor
        circleView?.layer.borderWidth = 1.0
        circleView?.layer.backgroundColor = UIColor.tinylogLightGray.cgColor
        circleView?.backgroundColor = UIColor.tinylogLightGray
        self.addSubview(circleView!)

        checkMarkIcon = UIImageView(image: UIImage(named: "check"))
        checkMarkIcon?.frame = CGRect(
            x: 30.0 / 2 - 16.0 / 2.0,
            y: 30.0 / 2.0 - 12.0 / 2.0,
            width: 16.0,
            height: 12.0)
        self.addSubview(checkMarkIcon!)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let area: CGRect = self.bounds.insetBy(dx: -20, dy: -20)
        return area.contains(point)
    }

}
