//
//  KeyboardBar.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

final class KeyboardBar: UIView, UIInputViewAudioFeedback {

    var keyInputView: UIKeyInput?
    let buttonHashTag: UIButton = UIButton()
    let buttonMention: UIButton = UIButton()

    var enableInputClicksWhenVisible: Bool {
        return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        backgroundColor = UIColor.tinylogNavigationBarDayColor
        buttonHashTag.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 20.0)
        buttonHashTag.setTitleColor(UIColor.tinylogMainColor, for: UIControl.State())
        buttonHashTag.setTitle("#", for: UIControl.State())
        buttonHashTag.addTarget(
            self,
            action: #selector(KeyboardBar.buttonHashTagPressed(_:)),
            for: UIControl.Event.touchUpInside)
        addSubview(buttonHashTag)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        buttonHashTag.frame = CGRect(x: 20.0,
                                     y: 1.0,
                                     width: 20.0,
                                     height: bounds.size.height - 1.0)
        buttonMention.frame = CGRect(x: 60.0,
                                     y: 1.0,
                                     width: 20.0,
                                     height: bounds.size.height - 1.0)
    }

    @objc func buttonHashTagPressed(_ button: UIButton) {
        UIDevice.current.playInputClick()
        keyInputView?.insertText("#")
    }
}
