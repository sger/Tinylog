//
//  SettingsTableViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_unwrapping
import UIKit
import MessageUI
import SVProgressHUD

protocol SettingsTableViewControllerDelegate: AnyObject {
    func settingsTableViewControllerDidTapButton()
}

class SettingsTableViewController: UITableViewController,
    MFMailComposeViewControllerDelegate,
    UIGestureRecognizerDelegate {

    weak var delegate: SettingsTableViewControllerDelegate?
    
    let settingsCellIdentifier = "SettingsCellIdentifier"

    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()

    // MARK: Initializers

    override init(style: UITableView.Style) {
        super.init(style: UITableView.Style.grouped)
    }

    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBarProperties()
        
        tableView?.backgroundColor = UIColor(named: "mainColor")
        tableView?.backgroundView = UIView()
        tableView?.backgroundView?.backgroundColor = UIColor.clear
        tableView?.separatorColor = UIColor(named: "tableViewSeparator")
        tableView?.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(SettingsTableViewController.close(_:)))
        
        
        title = "Settings"

        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SettingsTableViewController.updateFonts),
            name: NSNotification.Name(
                rawValue: Notifications.fontDidChangeNotification),
                object: nil)
    }

    @objc func updateFonts() {
        navigationController?.navigationBar.setNeedsDisplay()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // swiftlint:disable cyclomatic_complexity
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        cell.textLabel?.font = UIFont.tinylogFontOfSize(17.0)
        cell.textLabel?.textColor = UIColor(named: "textColor")

        cell.backgroundColor = UIColor(named: "mainColor")
        
        let selectedBackgroundView = UIView(frame: cell.frame)
        selectedBackgroundView.backgroundColor = UIColor(named: "tableViewSelected")
        selectedBackgroundView.contentMode = UIView.ContentMode.redraw
        cell.selectedBackgroundView = selectedBackgroundView

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "iCloud"
                cell.imageView?.image = UIImage(named: "706-cloud")
                let switchMode: UISwitch = UISwitch(
                    frame: CGRect(
                        x: 0,
                        y: 0,
                        width: view.frame.size.width,
                        height: 20.0))
                switchMode.addTarget(
                    self,
                    action: #selector(SettingsTableViewController.toggleSyncSettings(_:)),
                    for: UIControl.Event.valueChanged)
                switchMode.onTintColor = UIColor.tinylogMainColor
                cell.accessoryView = switchMode
                cell.accessoryType = UITableViewCell.AccessoryType.none

                let userDefaults = Environment.current.userDefaults
                let syncModeValue = userDefaults.bool(forKey: EnvUserDefaults.syncMode)

                if syncModeValue {
                    switchMode.setOn(true, animated: false)
                } else {
                    switchMode.setOn(false, animated: false)
                }
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Font"
                // swiftlint:disable line_length
                cell.detailTextLabel?.text = SettingsFontPickerViewController.textForSelectedKey() as String?
                cell.detailTextLabel?.font = UIFont.tinylogFontOfSize(16.0, key: SettingsFontPickerViewController.selectedKey()!)
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Text Size"
                cell.detailTextLabel?.font = UIFont.tinylogFontOfSize(16.0)

                let userDefaults = Environment.current.userDefaults
                let useSystemFontSize = userDefaults.bool(forKey: EnvUserDefaults.systemFontSize)

                if useSystemFontSize {
                    cell.detailTextLabel?.text = "System Size"
                } else {
                    let fontSize = userDefaults.double(forKey: EnvUserDefaults.fontSize)
                    let strFontSize = NSString(format: "%.f", fontSize)
                    cell.detailTextLabel?.text = strFontSize as String
                }
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Send Feedback"
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Rate Tinylog"
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "Help"
            }
        } else if indexPath.section == 3 {
            cell.textLabel?.text = "About"
        }
    }

    // MARK: Actions

    @objc func toggleSyncSettings(_ sender: UISwitch) {
        selectionFeedbackGenerator.selectionChanged()
        let mode: UISwitch = sender as UISwitch
        let value: NSString = mode.isOn == true ? "on" : "off"

        Environment.current.userDefaults.set(mode.isOn, forKey: EnvUserDefaults.syncMode)

        Utils.delay(0.2, closure: { () -> Void in
            let syncManager = TLISyncManager.shared()

            if value == "on" {
                syncManager?.connect(toSyncService: IDMICloudService, withCompletion: { (error) -> Void in
                    if error != nil {
                        if error?._code == 1003 {
                            SVProgressHUD.show()
                            SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
                            SVProgressHUD.setBackgroundColor(UIColor.tinylogMainColor)
                            SVProgressHUD.setForegroundColor(UIColor.white)
                            SVProgressHUD.setFont(UIFont.tinylogFontOfSize(14.0))
                            SVProgressHUD.showError(withStatus: "You are not logged in to iCloud.Tap Settings > iCloud to login.")
                        }
                    }
                })
            } else if value == "off" {
                if (syncManager?.canSynchronize())! {
                    syncManager?.disconnectFromSyncService(completion: { () -> Void in })
                }
            }
        })
    }

    @objc func close(_ sender: UIButton) {
        delegate?.settingsTableViewControllerDidTapButton()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel!.font = UIFont.regularFontWithSize(16.0)
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "SYNC"
        } else if section == 1 {
            return "DISPLAY"
        } else if section == 2 {
            return "FEEDBACK"
        } else if section == 3 {
            return ""
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 2
        } else if section == 2 {
            return 3
        } else if section == 3 {
            return 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .value1, reuseIdentifier: settingsCellIdentifier)
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    // swiftlint:disable cyclomatic_complexity
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var viewController: UIViewController?
        if indexPath.section == 0 {
            if indexPath.row == 0 {

            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                viewController = SettingsFontPickerViewController()
            } else if indexPath.row == 1 {
                viewController = TextSizeViewController()
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                if MFMailComposeViewController.canSendMail() {
                    let infoDictionary: NSDictionary = Bundle.main.infoDictionary! as NSDictionary
                    if let version: NSString = infoDictionary.object(forKey: "CFBundleShortVersionString") as? NSString,
                        let build: NSString = infoDictionary.object(forKey: "CFBundleVersion") as? NSString {
                    let deviceModel = TLIDeviceInfo.model()

                    let mailer: MFMailComposeViewController = MFMailComposeViewController()
                    mailer.mailComposeDelegate = self
                    mailer.setSubject("Tinylog \(version)")
                    mailer.setToRecipients(["feedback@tinylogapp.com"])

                    let systemVersion = UIDevice.current.systemVersion
                    let stringBody = "---\nApp: Tinylog \(version) (\(build))\nDevice: \(String(describing: deviceModel)) (\(systemVersion))"

                    mailer.setMessageBody(stringBody, isHTML: false)
                    let titleTextDict: NSDictionary = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.mediumFontWithSize(16.0)]

                    mailer.navigationBar.titleTextAttributes = titleTextDict as? [NSAttributedString.Key: Any]

                    mailer.navigationBar.tintColor = UIColor.tinylogMainColor
                    present(mailer, animated: true, completion: nil)
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
            } else if indexPath.row == 1 {
                if let path: URL = URL(string: "https://itunes.apple.com/gr/app/tinylog/id799267191?mt=8") {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(path, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(path)
                    }
                }
            } else if indexPath.row == 2 {
                viewController = HelpTableViewController()
            }
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                viewController = AboutViewController()
            }
        }
        if viewController != nil {
            if let vc = viewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    // MARK: MFMailComposeViewControllerDelegate

    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?) {
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
        self.dismiss(animated: true, completion: nil)
    }
}
