//
//  SetupViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import SVProgressHUD
import SnapKit

protocol SetupViewControllerDelegate: AnyObject {
    func setupViewControllerDismissed(_ viewController: SetupViewController)
}

final class SetupViewController: UIViewController {

    weak var delegate: SetupViewControllerDelegate?

    private var subtitleLabel: UILabel = {
        let subtitleLabel: UILabel = UILabel()
        subtitleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.numberOfLines = 1
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = UIColor.tinylogMainColor
        subtitleLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 34.0)
        subtitleLabel.text = localizedString(key: "Sync")
        return subtitleLabel
    }()

    private var descriptionLabel: UILabel = {
        let descriptionLabel: UILabel = UILabel()
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.numberOfLines = 3
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = UIColor.tinylogMainColor
        descriptionLabel.font = UIFont(name: "HelveticaNeue", size: 28.0)
        descriptionLabel.text = localizedString(key: "Sync_description")
        return descriptionLabel
    }()

    private var notNowButton: RoundedButton = {
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

    private var useiCloudButton: RoundedButton = {
        let useiCloudButton = RoundedButton()
        useiCloudButton.accessibilityIdentifier = "useiCloudButton"
        useiCloudButton.setTitle(localizedString(key: "Use_iCloud"), for: UIControl.State())
        useiCloudButton.addTarget(
            self,
            action: #selector(SetupViewController.enableiCloudAndDismiss(_:)),
            for: UIControl.Event.touchDown)
        useiCloudButton.backgroundColor = UIColor.tinylogMainColor
        return useiCloudButton
    }()

    private var cloudImageView: UIImageView = {
        let cloudImageView = UIImageView(image: UIImage(named: "cloud"))
        cloudImageView.translatesAutoresizingMaskIntoConstraints = false
        return cloudImageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = UIColor(named: "setupBackgroundColor")
        
        view.addSubview(cloudImageView)
        view.addSubview(notNowButton)
        view.addSubview(useiCloudButton)
        view.addSubview(subtitleLabel)
        view.addSubview(descriptionLabel)

        cloudImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-90)
            make.centerX.equalToSuperview()
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
        delegate?.setupViewControllerDismissed(self)
    }

    @objc func disableiCloudAndDismiss(_ button: RoundedButton) {
        Environment.current.userDefaults.set(false, forKey: EnvUserDefaults.setupScreen)
        Environment.current.userDefaults.set(false, forKey: EnvUserDefaults.syncMode)
        delegate?.setupViewControllerDismissed(self)
    }
}
