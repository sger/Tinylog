//
//  AddTaskView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

final class AddTaskView: UIView, UITextFieldDelegate {

    static let height: CGFloat = 54.0

    private let attributedPlaceholder = NSAttributedString(string: localizedString(key: "Add_new_task"),
                                                           attributes: [.foregroundColor: UIColor.tinylogLightGray])

    var textField: TLITextField = {
        let textField = TLITextField()
        textField.backgroundColor = UIColor.clear
        textField.font = UIFont.tinylogFontOfSize(17.0)
        textField.textColor = UIColor.tinylogLightGray
        textField.autocapitalizationType = UITextAutocapitalizationType.sentences
        textField.autocorrectionType = UITextAutocorrectionType.yes
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.textAlignment = NSTextAlignment.left
        textField.returnKeyType = UIReturnKeyType.done
        textField.tintColor = UIColor.tinylogLightGray
        return textField
    }()

    var closeButton: CloseButton = {
        let closeButton = CloseButton()
        closeButton.isHidden = true
        return closeButton
    }()

    weak var delegate: AddTaskViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = UIColor.tinylogMainColor

        textField.attributedPlaceholder = attributedPlaceholder
        textField.delegate = self
        addSubview(textField)

        textField.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().inset(10.0)
            maker.leading.equalToSuperview().inset(22.0)
            maker.trailing.equalToSuperview().inset(50.0)
            maker.bottom.equalToSuperview().inset(10.0)
        }

        addSubview(closeButton)

        closeButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 18.0, height: 18.0))
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16.0)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AddTaskView.updateFonts),
                                               name: NSNotification.Name(rawValue: Notifications.fontDidChangeNotification),
                                               object: nil)

        setNeedsUpdateConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func updateFonts() {
        textField.font = UIFont.tinylogFontOfSize(17.0)
    }

    // MARK: UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.addTaskViewDidBeginEditing(self)
        textField.attributedPlaceholder = nil
        closeButton.isHidden = false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.addTaskViewDidEndEditing(self)
        textField.attributedPlaceholder = attributedPlaceholder
        closeButton.isHidden = true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if let text = textField.text, text.length() == 0 {
            textField.resignFirstResponder()
            return false
        }

        if let text = textField.text {
            textField.text = nil
            delegate?.addTaskView(self, title: text)
        }

        return false
    }

    func reset() {
        textField.resignFirstResponder()
        textField.text = nil
        closeButton.isHidden = true
    }
}
