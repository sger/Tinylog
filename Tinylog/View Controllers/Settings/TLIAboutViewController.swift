//
//  TLIAboutViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import MessageUI

class TLIAboutViewController: TLIGroupedTableViewController,
    UIGestureRecognizerDelegate,
    MFMailComposeViewControllerDelegate {
    let aboutCellIdentifier = "AboutCellIdentifier"

    // MARK: Initializers

    override init() {
        super.init(style: UITableView.Style.grouped)
    }

    override init(style: UITableView.Style) {
        super.init(style: style)

    }

    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "About"
        self.view.backgroundColor = UIColor.tinylogLightGray
        self.tableView?.backgroundColor = UIColor.tinylogLightGray
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(
            name: Notification.Name(
                rawValue: Notifications.fontDidChangeNotification),
                object: nil)
    }

    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {

        cell.textLabel?.font = UIFont.tinylogFontOfSize(17.0)
        cell.textLabel?.textColor = UIColor.tinylogTextColor
        cell.detailTextLabel?.font = UIFont.tinylogFontOfSize(15.0)

        let selectedBackgroundView = UIView(frame: cell.frame)
        selectedBackgroundView.backgroundColor = UIColor.tinylogLighterGray
        selectedBackgroundView.contentMode = UIView.ContentMode.redraw
        cell.selectedBackgroundView = selectedBackgroundView

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Version"
                if let versionInfo = PlistInfo.versionInfo() {
                    cell.detailTextLabel?.text = versionInfo
                }
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Web"
                cell.detailTextLabel?.text = "http://binarylevel.github.io/tinylog/"
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Email"
                cell.detailTextLabel?.text = "spiros.gerokostas@gmail.com"
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "Twitter"
                cell.detailTextLabel?.text = "@tinylogapp"
            }
        }
    }

    // MARK: Actions

    func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView()
            view.frame = CGRect(x: 0.0, y: 0.0, width: self.tableView.frame.size.width, height: 44.0)
            let label = UILabel(
                frame: CGRect(
                    x: 17.0,
                    y: 5.0,
                    width: self.tableView.frame.size.width - 17.0,
                    height: 44.0))
            view.addSubview(label)
            label.numberOfLines = 0
            label.font = UIFont.tinylogFontOfSize(14.0)
            label.textColor = UIColor.tinylogTextColor
            label.text = "Logo created by John Anagnostou \n(behance.net/tzoAnagnostou)"
            label.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(
                target: self,
                action: #selector(TLIAboutViewController.viewWebsite))
            label.addGestureRecognizer(tap)
            return view
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44.0
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 3
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(
            style: UITableViewCell.CellStyle.value1, reuseIdentifier: aboutCellIdentifier)
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    // swiftlint:disable cyclomatic_complexity
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                if let path: URL = URL(string: "http://binarylevel.github.io/tinylog/") {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(path,
                                                  options: [:],
                                                  completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(path)
                    }
                }
            } else if indexPath.row == 1 {
                if MFMailComposeViewController.canSendMail() {
                    if let versionInfo = PlistInfo.versionInfo() {
                        let deviceModel = TLIDeviceInfo.model()
                        let mailer: MFMailComposeViewController = MFMailComposeViewController()
                        mailer.mailComposeDelegate = self
                        mailer.setSubject("Tinylog \(versionInfo)")
                        mailer.setToRecipients(["spiros.gerokostas@gmail.com"])
                        let systemVersion = UIDevice.current.systemVersion
                        // swiftlint:disable line_length
                        let stringBody = "---\nApp: Tinylog \(versionInfo)\nDevice: \(String(describing: deviceModel)) (\(systemVersion))"
                        mailer.setMessageBody(stringBody, isHTML: false)
                        let titleTextDict: NSDictionary = [
                            NSAttributedString.Key.foregroundColor: UIColor.black,
                            NSAttributedString.Key.font: UIFont.mediumFontWithSize(16.0)]
                        mailer.navigationBar.titleTextAttributes = titleTextDict as? [NSAttributedString.Key: Any]
                        mailer.navigationBar.tintColor = UIColor.tinylogMainColor
                        self.present(mailer, animated: true, completion: nil)
                        mailer.viewControllers.last?.navigationItem.title = "Tinylog"
                    }
                } else {
                    let alert = UIAlertController(title: "Tinylog",
                                                  message: "Your device doesn't support this feature",
                                                  preferredStyle: UIAlertController.Style.alert)

                    let cancelAction = UIAlertAction(title: "OK",
                                                     style: .cancel, handler: nil)

                    alert.addAction(cancelAction)
                    present(alert, animated: true)
                }
            } else if indexPath.row == 2 {
                if let path: URL = URL(string: "https://twitter.com/tinylogapp") {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(path, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(path)
                    }
                }
            }
        }
    }

    @objc func viewWebsite() {
        if let path: URL = URL(string: "https://www.behance.net/tzoAnagnostou") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(path, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(path)
            }
        }
    }

    // MARK: MFMailComposeViewControllerDelegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            break
        case MFMailComposeResult.saved.rawValue:
            break
        case MFMailComposeResult.sent.rawValue:
            break
        case MFMailComposeResult.failed.rawValue:
            break
        default:
            break
        }
        self.dismiss(animated: true, completion: { () -> Void in

        })
    }
}
