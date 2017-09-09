//
//  TLIEditTaskViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_unwrapping
import UIKit

class TLIEditTaskViewController: UIViewController {

    var indexPath: IndexPath?
    var task: TLITask?
    var textView: UITextView?
    var keyboardRect: CGRect?
    var delegate: TLIEditTaskViewControllerDelegate?
    var saveOnClose: Bool = true
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Task"
        self.view.backgroundColor = UIColor.white

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(TLIEditTaskViewController.close(_:)))

        let saveBarButtonItem: UIBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(TLIEditTaskViewController.save(_:)))

        self.navigationItem.rightBarButtonItems = [saveBarButtonItem]

        textView = UITextView(frame: CGRect.zero)
        textView?.autocorrectionType = UITextAutocorrectionType.yes
        textView?.bounces = true
        textView?.alwaysBounceVertical = true
        textView?.text = task?.displayLongText
        textView?.textColor = UIColor.tinylogTextColor
        textView?.font = UIFont.tinylogFontOfSize(17.0)
        self.view.addSubview(textView!)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TLIEditTaskViewController.keyboardWillShow(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TLIEditTaskViewController.keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil)
    }

    func keyboardWillShow(_ notification: Notification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        keyboardRect = self.view.convert((
            userInfo.object(
                forKey: UIKeyboardFrameEndUserInfoKey)! as AnyObject).cgRectValue, from: nil)
        let duration: Double = (userInfo.object(
            forKey: UIKeyboardAnimationDurationUserInfoKey)! as AnyObject).doubleValue
        layoutTextView(duration)
    }

    func keyboardWillHide(_ notification: Notification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        keyboardRect = CGRect.zero
        let size: CGSize = self.view.bounds.size
        var heightAdjust: CGFloat

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            heightAdjust = 2.0
        } else {
            heightAdjust = keyboardRect!.size.height
        }

        let textViewHeight = size.height - heightAdjust //- 44.0

        UIView.animate(withDuration: TimeInterval((userInfo.object(
            forKey: UIKeyboardAnimationDurationUserInfoKey)! as AnyObject).floatValue),
                       delay: TimeInterval(0.0),
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: { () -> Void in
                        self.textView?.frame = CGRect(
                            x: 0.0,
                            y: 0.0,
                            width: size.width,
                            height: textViewHeight)
                        return
            }, completion: { (_:Bool) -> Void in

        })
    }

    func close(_ sender: UIButton) {
        saveOnClose = false
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    func save(_ sender: UIButton) {
        saveOnClose = true
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        UIView.animate(withDuration: duration, delay: 0.0,
            options: .allowUserInteraction, animations: {
                self.layoutTextView(duration)
            }, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardRect = CGRect.zero
        layoutTextView(0.0)
        textView?.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideKeyboard()

        if saveOnClose {
            task?.displayLongText = textView!.text
            // swiftlint:disable force_try
            try! managedObjectContext.save()

            delegate?.onClose(self, indexPath: indexPath!)
        }
    }

    func layoutTextView(_ duration: TimeInterval) {
        let size: CGSize = self.view.bounds.size
        var heightAdjust: CGFloat

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            heightAdjust = 2.0
        } else {
            heightAdjust = keyboardRect!.size.height
        }

        let textViewHeight = size.height - heightAdjust //- 44.0

        UIView.animate(
            withDuration: TimeInterval(duration),
            delay: TimeInterval(0.0),
            options: UIViewAnimationOptions.allowUserInteraction,
            animations: { () -> Void in
                self.textView?.frame = CGRect(
                    x: 0.0,
                    y: 0.0,
                    width: size.width,
                    height: textViewHeight)
                return
            }, completion: { (_:Bool) -> Void in
        })
    }

    func hideKeyboard() {
        self.view.endEditing(true)
    }
}
