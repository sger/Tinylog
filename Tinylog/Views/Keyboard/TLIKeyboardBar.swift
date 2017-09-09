//
//  TLIKeyboardBar.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLIKeyboardBar: UIView, UIInputViewAudioFeedback {

    var keyInputView: UIKeyInput?
    let buttonHashTag: UIButton = UIButton()
    let buttonMention: UIButton = UIButton()

    var enableInputClicksWhenVisible: Bool {
        return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.autoresizingMask = UIViewAutoresizing.flexibleWidth
        self.backgroundColor = UIColor.tinylogNavigationBarDayColor
        // swiftlint:disable force_unwrapping
        buttonHashTag.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 20.0)
        buttonHashTag.setTitleColor(UIColor.tinylogMainColor, for: UIControlState())
        buttonHashTag.setTitle("#", for: UIControlState())
        buttonHashTag.addTarget(
            self,
            action: #selector(TLIKeyboardBar.buttonHashTagPressed(_:)),
            for: UIControlEvents.touchUpInside)
        self.addSubview(buttonHashTag)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        buttonHashTag.frame = CGRect(x: 20.0, y: 1.0, width: 20.0, height: self.bounds.size.height - 1.0)
        buttonMention.frame = CGRect(x: 60.0, y: 1.0, width: 20.0, height: self.bounds.size.height - 1.0)
    }

    func buttonHashTagPressed(_ button: UIButton) {
        UIDevice.current.playInputClick()
        keyInputView?.insertText("#")
    }
}
