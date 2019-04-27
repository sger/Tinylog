//
//  SetupViewControllerTests.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 27/04/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import XCTest
@testable import Tinylog
import SnapshotTesting

class SetupViewControllerTests: XCTestCase {

    func testSetupViewControllerWithEnLanguage() {
        testWithEnvironment(language: .en, block: {
            let vc = SetupViewController()
            assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
            assertSnapshot(matching: vc, as: .recursiveDescription(on: .iPhoneX(.portrait)))
            
            assertSnapshot(matching: vc, as: .image(on: .iPhoneXsMax))
            assertSnapshot(matching: vc, as: .recursiveDescription(on: .iPhoneXsMax(.portrait)))
        })
    }
    
    func testSetupViewControllerWithDeLanguage() {
        testWithEnvironment(language: .de, block: {
            let vc = SetupViewController()
            assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
            assertSnapshot(matching: vc, as: .recursiveDescription(on: .iPhoneX(.portrait)))
            
            assertSnapshot(matching: vc, as: .image(on: .iPhoneXsMax))
            assertSnapshot(matching: vc, as: .recursiveDescription(on: .iPhoneXsMax(.portrait)))
        })
    }
}
