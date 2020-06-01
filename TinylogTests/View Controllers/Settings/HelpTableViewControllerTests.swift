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
                
        testWithEnvironment(language: .en, userDefaults: userDefaults, block: {
            let vc = HelpTableViewController()
            assertSnapshot(matching: vc, as: .image)
        })
    }

    func testHelpTableViewControllerInLandscapeMode() {
        
        let userDefaults = MockUserDefaults()
        userDefaults.set(21.0, forKey: EnvUserDefaults.fontSize)
        userDefaults.set(kTLIFontHelveticaNeueKey, forKey: String(kTLIFontDefaultsKey))
                
        testWithEnvironment(language: .en, userDefaults: userDefaults, block: {
            let vc = HelpTableViewController()
            assertSnapshot(matching: vc, as: .image)
        })
    }
}
