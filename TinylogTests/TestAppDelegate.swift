//
//  TestAppDelegate.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 1/6/20.
//  Copyright © 2020 Spiros Gerokostas. All rights reserved.
//

import UIKit

@objc(TestAppDelegate)
class TestAppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("Running the unit tests with TestAppDelegate")
        return true
    }
}
