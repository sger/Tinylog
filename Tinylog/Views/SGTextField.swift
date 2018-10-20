//
//  SGTextField.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 21/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_unwrapping
import UIKit

class SGTextField: UITextField {

    var placeholderTextColor: UIColor?
    var textEdgeInsets: UIEdgeInsets?
    var clearButtonEdgeInsets: UIEdgeInsets?

    override init(frame: CGRect) {
        super.init(frame: frame)
         setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        textEdgeInsets = UIEdgeInsets.zero
        clearButtonEdgeInsets = UIEdgeInsets.zero
    }

    // MARK: UITextField

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds).inset(by: textEdgeInsets!)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds: bounds)
    }

    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRect(forBounds: bounds)
        rect = CGRectSetY(rect, rect.origin.y + (clearButtonEdgeInsets?.top)!)
        return CGRectSetX(rect, rect.origin.x + (clearButtonEdgeInsets?.right)!)
    }
}
