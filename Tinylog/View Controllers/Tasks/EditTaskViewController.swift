//
//  EditTaskViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_unwrapping
import UIKit

final class EditTaskViewController: UIViewController {

    var indexPath: IndexPath?
    var task: TLITask?
    var textView: UITextView?
    var keyboardRect: CGRect?
    weak var delegate: EditTaskViewControllerDelegate?
    var saveOnClose: Bool = true
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Task"

        setupNavigationBarProperties()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(EditTaskViewController.close(_:)))

        let saveBarButtonItem: UIBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(EditTaskViewController.save(_:)))

        navigationItem.rightBarButtonItems = [saveBarButtonItem]

        textView = UITextView(frame: CGRect.zero)
        textView?.autocorrectionType = UITextAutocorrectionType.yes
        textView?.bounces = true
        textView?.alwaysBounceVertical = true
        textView?.text = task?.displayLongText
        textView?.textColor = UIColor(named: "textColor")
        textView?.font = UIFont.tinylogFontOfSize(17.0)
        view.addSubview(textView!)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(EditTaskViewController.keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(EditTaskViewController.keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        keyboardRect = self.view.convert((
            userInfo.object(
                forKey: UIResponder.keyboardFrameEndUserInfoKey)! as AnyObject).cgRectValue, from: nil)
        let duration: Double = (userInfo.object(
            forKey: UIResponder.keyboardAnimationDurationUserInfoKey)! as AnyObject).doubleValue
        layoutTextView(duration)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        keyboardRect = CGRect.zero
        let size: CGSize = view.bounds.size
        var heightAdjust: CGFloat

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            heightAdjust = 2.0
        } else {
            heightAdjust = keyboardRect!.size.height
        }

        let textViewHeight = size.height - heightAdjust // - 44.0

        UIView.animate(withDuration: TimeInterval((userInfo.object(
            forKey: UIResponder.keyboardAnimationDurationUserInfoKey)! as AnyObject).floatValue),
                       delay: TimeInterval(0.0),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: { () -> Void in
                        self.textView?.frame = CGRect(
                            x: 0.0,
                            y: 0.0,
                            width: size.width,
                            height: textViewHeight)
                        return
            }, completion: { (_: Bool) -> Void in

        })
    }

    @objc func close(_ sender: UIButton) {
        saveOnClose = false
        navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func save(_ sender: UIButton) {
        saveOnClose = true
        navigationController?.dismiss(animated: true, completion: nil)
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

        let textViewHeight = size.height - heightAdjust // - 44.0

        UIView.animate(
            withDuration: TimeInterval(duration),
            delay: TimeInterval(0.0),
            options: UIView.AnimationOptions.allowUserInteraction,
            animations: { () -> Void in
                self.textView?.frame = CGRect(
                    x: 0.0,
                    y: 0.0,
                    width: size.width,
                    height: textViewHeight)
                return
            }, completion: { (_: Bool) -> Void in
        })
    }

    func hideKeyboard() {
        view.endEditing(true)
    }
}
