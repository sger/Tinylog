//
//  TextFieldCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_unwrapping
import UIKit

final class TextFieldCell: UITableViewCell, UITextFieldDelegate, TextFieldCellDelegate {
    
    static let cellIdentifier = "TextFieldCell"

    var textField: TLITextField?
    var indexPath: IndexPath?
    var delegate: TextFieldCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear

        textField = TLITextField(frame: CGRect.zero)
        textField?.clearsOnBeginEditing = false
        textField?.clearButtonMode = UITextField.ViewMode.whileEditing
        textField?.textAlignment = NSTextAlignment.left
        textField?.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField?.keyboardAppearance = UIKeyboardAppearance.light
        textField?.adjustsFontSizeToFitWidth = true
        textField?.delegate = self
        textField?.font = UIFont.regularFontWithSize(17.0)
        textField?.textColor = UIColor(named: "textColor")
        textField?.clearButtonEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: -20.0)
        self.contentView.addSubview(textField!)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        delegate = nil
        textField?.resignFirstResponder()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let frame: CGRect = self.contentView.frame

        if textField?.text != nil || textField?.placeholder != nil {
            textField?.isHidden = false
            textField?.frame = CGRect(
                x: frame.origin.x + 16.0,
                y: frame.origin.y,
                width: frame.size.width,
                height: frame.size.height)
            textField?.autocapitalizationType = UITextAutocapitalizationType.none
        }
        self.setNeedsDisplay()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let value = delegate?.shouldReturnForIndexPath!(indexPath!, value: textField.text!)
        if value != nil {
            textField.resignFirstResponder()
        }
        return value!
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
            var textString: NSString = textField.text! as NSString
            textString = textString.replacingCharacters(in: range, with: string) as NSString
            delegate?.updateTextLabelAtIndexPath!(indexPath!, value: textString as String)
            return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        delegate?.updateTextLabelAtIndexPath!(indexPath!, value: textField.text!)
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        _ = delegate?.textFieldShouldBeginEditing!(textField)
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        _ = delegate?.textFieldShouldEndEditing!(textField)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidBeginEditing!(textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldDidEndEditing!(textField)
    }
}
