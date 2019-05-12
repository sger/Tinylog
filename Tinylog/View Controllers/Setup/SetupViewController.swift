//
//  SetupViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_unwrapping
import UIKit
import SVProgressHUD

final class SetupViewController: UIViewController {

    lazy var subtitleLabel: UILabel = {
        let subtitleLabel: UILabel = UILabel()
        subtitleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.numberOfLines = 1
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = UIColor.tinylogMainColor
        subtitleLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 34.0)
        subtitleLabel.text = localizedString(key: "Sync")
        return subtitleLabel
    }()

    lazy var descriptionLabel: UILabel = {
        let descriptionLabel: UILabel = UILabel()
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.numberOfLines = 3
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = UIColor.tinylogMainColor
        descriptionLabel.font = UIFont(name: "HelveticaNeue", size: 28.0)
        descriptionLabel.text = localizedString(key: "Sync_description")
        return descriptionLabel
    }()

    lazy var notNowButton: RoundedButton = {
        let notNowButton = RoundedButton()
        notNowButton.accessibilityIdentifier = "notNowButton"
        notNowButton.setTitle(localizedString(key: "Later"), for: UIControl.State())
        notNowButton.backgroundColor = UIColor.tinylogTextColor
        notNowButton.addTarget(
            self,
            action: #selector(SetupViewController.disableiCloudAndDismiss(_:)),
            for: UIControl.Event.touchDown)
        return notNowButton
    }()

    lazy var useiCloudButton: RoundedButton = {
        let useiCloudButton = RoundedButton()
        notNowButton.accessibilityIdentifier = "useiCloudButton"
        useiCloudButton.setTitle(localizedString(key: "Use_iCloud"), for: UIControl.State())
        useiCloudButton.addTarget(
            self,
            action: #selector(SetupViewController.enableiCloudAndDismiss(_:)),
            for: UIControl.Event.touchDown)
        useiCloudButton.backgroundColor = UIColor.tinylogMainColor
        return useiCloudButton
    }()

    lazy var cloudImageView: UIImageView = {
        let cloudImageView = UIImageView(image: UIImage(named: "cloud"))
        cloudImageView.translatesAutoresizingMaskIntoConstraints = false
        return cloudImageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = UIColor.tinylogLightGray
        
        cloudImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-90)
            make.centerX.equalToSuperview().offset
        }
        
        subtitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(20.0)
            make.right.equalToSuperview().inset(20.0)
            make.top.equalTo(cloudImageView.snp.bottom).offset(20.0)
        }
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(20.0)
            make.right.equalToSuperview().inset(20.0)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20.0)
        }
        
        notNowButton.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(60.0)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        useiCloudButton.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(60.0)
            make.left.equalTo(notNowButton.snp.right)
            make.bottom.equalToSuperview()
        }
    }

    override func loadView() {
        self.view = UIView()
        self.view.addSubview(cloudImageView)
        self.view.addSubview(notNowButton)
        self.view.addSubview(useiCloudButton)
        self.view.addSubview(subtitleLabel)
        self.view.addSubview(descriptionLabel)
        self.view.setNeedsUpdateConstraints()
    }

    @objc func enableiCloudAndDismiss(_ button: RoundedButton) {
        Environment.current.userDefaults.set(false, forKey: EnvUserDefaults.setupScreen)
        Environment.current.userDefaults.set(true, forKey: EnvUserDefaults.syncMode)

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
                        withStatus: localizedString(key: "Not_logged_in"))
                }
            }
        })
        dismiss(animated: true, completion: nil)
    }

    @objc func disableiCloudAndDismiss(_ button: RoundedButton) {
        Environment.current.userDefaults.set(false, forKey: EnvUserDefaults.setupScreen)
        Environment.current.userDefaults.set(false, forKey: EnvUserDefaults.syncMode)
        dismiss(animated: true, completion: nil)
    }
}
