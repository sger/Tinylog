//
//  TLITableViewCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_unwrapping
import UIKit

class TLITableViewCell: UITableViewCell {

    var editingText: Bool?
    var editingTapGestureRecognizer: UITapGestureRecognizer?
    var editingLongPressGestureRecognizer: UILongPressGestureRecognizer?

    var textField: TLITextField? {
        didSet {
            if !(textField != nil) {
                textField = TLITextField(frame: CGRect.zero)
                textField?.textColor = self.textLabel!.textColor
                textField?.placeholderTextColor = UIColor.tinylogNavigationBarColor
                textField?.backgroundColor = UIColor.white
                textField?.contentVerticalAlignment = UIControlContentVerticalAlignment.center
                textField?.returnKeyType = UIReturnKeyType.done
                textField?.alpha = 0.0
                self.updateFonts()
                self.contentView.addSubview(textField!)
            }
        }
    }

    func setEditingText(_ editingText: Bool) {
        self.editingText = editingText

        if self.editingText! {

            self.contentView.addSubview(self.textField!)
            self.setNeedsLayout()
            textField?.becomeFirstResponder()

            UIView.animate(
                withDuration: TimeInterval(0.4),
                delay: TimeInterval(0.0),
                options: UIViewAnimationOptions(),
                animations: { () -> Void in
                    self.textField?.alpha = 1
                    return
                }, completion: { (_:Bool) -> Void in
            })

        } else {
            textField?.resignFirstResponder()
            UIView.animate(
                withDuration: TimeInterval(0.4),
                delay: TimeInterval(0.0),
                options: UIViewAnimationOptions(),
                animations: { () -> Void in
                    self.textField?.alpha = 0.0
                    return
                }, completion: { (_:Bool) -> Void in
                    self.textField?.removeFromSuperview()
                    self.textField = nil
            })
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel!.textColor = UIColor.tinylogTextColor
        self.updateFonts()

        self.contentView.clipsToBounds = true

        editingTapGestureRecognizer = UITapGestureRecognizer()
        editingTapGestureRecognizer?.delegate = self
        self.addGestureRecognizer(editingTapGestureRecognizer!)

        editingLongPressGestureRecognizer = UILongPressGestureRecognizer()
        editingLongPressGestureRecognizer?.delegate = self
        self.addGestureRecognizer(editingLongPressGestureRecognizer!)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TLITableViewCell.updateFonts),
            name: NSNotification.Name(
                rawValue: TLINotifications.kTLIFontDidChangeNotification as String),
                object: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if !selected {
            self.textLabel!.backgroundColor = UIColor.clear
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.setEditingText(false)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        editingTapGestureRecognizer?.isEnabled = editing
    }

    class func cellHeight() -> CGFloat {
        return 51.0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGSize = self.contentView.bounds.size

        if self.isEditing {
            textField?.frame = CGRect(x: 14.0, y: 0.0, width: size.width - 46.0, height: size.height - 2.0)
        }
    }

    func updateFonts() {
        textField?.font = self.textLabel!.font
        self.textLabel!.font = UIFont.tinylogFontOfSize(18.0)
    }

    override func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch) -> Bool {
        return touch.view!.isKind(of: UIControl.self) == false
    }

    func setEditingAction(_ editAction: Selector, target: AnyObject) {
        editingTapGestureRecognizer?.addTarget(target, action: editAction)
        editingLongPressGestureRecognizer?.addTarget(target, action: editAction)
    }
}
