//
//  TLISetupViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_unwrapping
import UIKit
import PureLayout
import SVProgressHUD

class TLISetupViewController: UIViewController {

    var didSetupConstraints = false

    lazy var subtitleLabel: UILabel? = {
        let subtitleLabel: UILabel = UILabel.newAutoLayout()
        subtitleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.numberOfLines = 1
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = UIColor.tinylogMainColor
        subtitleLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 34.0)
        subtitleLabel.text = "iCloud for Tinylog"
        return subtitleLabel
    }()

    lazy var descriptionLabel: UILabel? = {
        let descriptionLabel: UILabel = UILabel.newAutoLayout()
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.numberOfLines = 3
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = UIColor.tinylogMainColor
        descriptionLabel.font = UIFont(name: "HelveticaNeue", size: 28.0)
        descriptionLabel.text = "iCloud keeps your lists up to date on your iPhone and iPad."
        return descriptionLabel
    }()

    lazy var notNowButton: TLIRoundedButton = {
        let notNowButton = TLIRoundedButton.newAutoLayout()
        notNowButton.setTitle("Later", for: UIControlState())
        notNowButton.backgroundColor = UIColor.tinylogTextColor
        notNowButton.addTarget(
            self,
            action: #selector(TLISetupViewController.disableiCloudAndDismiss(_:)),
            for: UIControlEvents.touchDown)
        return notNowButton
    }()

    lazy var useiCloudButton: TLIRoundedButton = {
        let useiCloudButton = TLIRoundedButton.newAutoLayout()
        useiCloudButton.setTitle("Use iCloud", for: UIControlState())
        useiCloudButton.addTarget(
            self,
            action: #selector(TLISetupViewController.enableiCloudAndDismiss(_:)),
            for: UIControlEvents.touchDown)
        useiCloudButton.backgroundColor = UIColor.tinylogMainColor
        return useiCloudButton
    }()

    lazy var cloudImageView: UIImageView? = {
        let cloudImageView = UIImageView(image: UIImage(named: "cloud"))
        cloudImageView.translatesAutoresizingMaskIntoConstraints = false
        return cloudImageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = UIColor(
            red: 250.0 / 255.0,
            green: 250.0 / 255.0,
            blue: 250.0 / 255.0,
            alpha: 1.0)
    }

    override func loadView() {
        self.view = UIView()
        self.view.addSubview(cloudImageView!)
        self.view.addSubview(notNowButton)
        self.view.addSubview(useiCloudButton)
        self.view.addSubview(subtitleLabel!)
        self.view.addSubview(descriptionLabel!)
        self.view.setNeedsUpdateConstraints()
    }

    override func updateViewConstraints() {

        if !didSetupConstraints {

            cloudImageView!.autoAlignAxis(ALAxis.horizontal, toSameAxisOf: self.view, withOffset: -90.0)
            cloudImageView!.autoAlignAxis(ALAxis.vertical, toSameAxisOf: self.view, withOffset: 0.0)

            subtitleLabel!.autoPinEdge(toSuperviewEdge: .leading, withInset: 20.0)
            subtitleLabel!.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20.0)
            subtitleLabel!.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: cloudImageView!, withOffset: 20.0)

            descriptionLabel!.autoPinEdge(toSuperviewEdge: .leading, withInset: 20.0)
            descriptionLabel!.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20.0)
            descriptionLabel!.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: subtitleLabel!, withOffset: 20.0)

            notNowButton.autoMatch(.width, to: .width, of: self.view, withMultiplier: 0.5)
            notNowButton.autoSetDimension(.height, toSize: 55.0)
            notNowButton.autoPinEdge(toSuperviewEdge: .left)
            notNowButton.autoPinEdge(toSuperviewEdge: .bottom)

            useiCloudButton.autoMatch(.width, to: .width, of: self.view, withMultiplier: 0.5)
            useiCloudButton.autoSetDimension(.height, toSize: 55.0)
            useiCloudButton.autoPinEdge(toSuperviewEdge: .bottom)
            useiCloudButton.autoPinEdge(.left, to: .right, of: notNowButton)

            didSetupConstraints = true
        }

        super.updateViewConstraints()
    }

    func enableiCloudAndDismiss(_ button: TLIRoundedButton) {

        let userDefaults = UserDefaults.standard
        userDefaults.set("off", forKey: "kSetupScreen")
        userDefaults.set("on", forKey: TLIUserDefaults.kTLISyncMode as String)
        userDefaults.synchronize()

        let syncManager = TLISyncManager.shared()
        syncManager?.connect(toSyncService: IDMICloudService, withCompletion: { (error) -> Void in
            if error != nil {
                if error?._code == 1003 {
                    SVProgressHUD.show()
                    SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
                    SVProgressHUD.setBackgroundColor(UIColor.tinylogMainColor)
                    SVProgressHUD.setForegroundColor(UIColor.white)
                    SVProgressHUD.setFont(UIFont(name: "HelveticaNeue", size: 14.0)!)
                    SVProgressHUD.showError(
                        withStatus: "You are not logged in to iCloud.Tap Settings > iCloud to login.")
                }
            }
        })

        self.dismiss(animated: true, completion: nil)
        TLIAnalyticsTracker.trackMixpanelEvent("Enable iCloud", properties: nil)
    }

    func disableiCloudAndDismiss(_ button: TLIRoundedButton) {

        let userDefaults = UserDefaults.standard
        userDefaults.set("off", forKey: "kSetupScreen")
        userDefaults.set("off", forKey: TLIUserDefaults.kTLISyncMode as String)
        userDefaults.synchronize()

        self.dismiss(animated: true, completion: nil)

        TLIAnalyticsTracker.trackMixpanelEvent("Disable iCloud", properties: nil)
    }
}
