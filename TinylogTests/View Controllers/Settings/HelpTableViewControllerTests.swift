//
//  HelpTableViewControllerTests.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 29/04/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import XCTest
@testable import Tinylog
import SnapshotTesting

class HelpTableViewControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
//        record = true
    }
    
    func testHelpTableViewControllerInPortaitMode() {
        
        let userDefaults = MockUserDefaults()
        userDefaults.set(21.0, forKey: EnvUserDefaults.fontSize)
        userDefaults.set(kTLIFontHelveticaNeueKey, forKey: String(kTLIFontDefaultsKey))
        
        combos(Language.languages, SnapshotTestingDevices.portrait).forEach { language, device in
            testWithEnvironment(language: language, userDefaults: userDefaults, block: {
                let vc = HelpTableViewController()
                assertSnapshot(matching: vc, as: .image(on: device))
                assertSnapshot(matching: vc, as: .recursiveDescription(on: device))
            })
        }
    }

    func testHelpTableViewControllerInLandscapeMode() {
        
        let userDefaults = MockUserDefaults()
        userDefaults.set(21.0, forKey: EnvUserDefaults.fontSize)
        userDefaults.set(kTLIFontHelveticaNeueKey, forKey: String(kTLIFontDefaultsKey))
        
        combos(Language.languages, SnapshotTestingDevices.landscape).forEach { language, device in
            testWithEnvironment(language: language, userDefaults: userDefaults, block: {
                let vc = HelpTableViewController()
                assertSnapshot(matching: vc, as: .image(on: device))
                assertSnapshot(matching: vc, as: .recursiveDescription(on: device))
            })
        }
    }
}
