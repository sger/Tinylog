//
//  AddTaskView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_unwrapping
import UIKit

class AddTaskView: UIView, UITextFieldDelegate {

    var textField: TLITextField? = {
        let textField = TLITextField.newAutoLayout()
        textField.backgroundColor = UIColor.clear
        textField.font = UIFont.tinylogFontOfSize(17.0)
        textField.textColor = UIColor.tinylogLightGray
        textField.placeholder = "Add new task"
        textField.setValue(UIColor.tinylogLightGray, forKeyPath: "_placeholderLabel.textColor")
        textField.autocapitalizationType = UITextAutocapitalizationType.sentences
        textField.autocorrectionType = UITextAutocorrectionType.yes
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.textAlignment = NSTextAlignment.left
        textField.returnKeyType = UIReturnKeyType.done
        textField.tintColor = UIColor.tinylogLightGray
        return textField
    }()

    var closeButton: CloseButton? = {
        let closeButton = CloseButton.newAutoLayout()
        closeButton.isHidden = true
        return closeButton
    }()

    var delegate: AddTaskViewDelegate?
    var didSetupContraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.backgroundColor = UIColor.tinylogMainColor

        textField!.delegate = self
        self.addSubview(textField!)

        self.addSubview(closeButton!)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AddTaskView.updateFonts),
                                               name: NSNotification.Name(rawValue: Notifications.fontDidChangeNotification),
                                               object: nil)
        setNeedsUpdateConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class func height() -> CGFloat {
        return 44.0
    }

    @objc func updateFonts() {
        textField?.font = UIFont.tinylogFontOfSize(17.0)
    }

    // MARK: UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.addTaskViewDidBeginEditing!(self)
        textField.placeholder = ""
        closeButton?.isHidden = false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.addTaskViewDidEndEditing!(self)
        textField.placeholder = "Add new task"
        closeButton?.isHidden = true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text!.length() == 0 {
            textField.resignFirstResponder()
            return false
        }

        let title: NSString = textField.text! as NSString
        textField.text = nil
        delegate?.addTaskView(self, title: title)
        return false
    }

    override func updateConstraints() {

        let smallPadding: CGFloat = 16.0

        if !didSetupContraints {

            textField!.autoPinEdge(toSuperviewEdge: .top, withInset: 10.0)
            textField!.autoPinEdge(toSuperviewEdge: .leading, withInset: 16.0)
            textField!.autoPinEdge(toSuperviewEdge: .trailing, withInset: 50.0)
            textField!.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10.0)

            closeButton?.autoSetDimensions(to: CGSize(width: 18.0, height: 18.0))
            closeButton?.autoAlignAxis(toSuperviewAxis: .horizontal)
            closeButton?.autoPinEdge(toSuperviewEdge: .right, withInset: smallPadding)

            didSetupContraints = true
        }
        super.updateConstraints()
    }
}
