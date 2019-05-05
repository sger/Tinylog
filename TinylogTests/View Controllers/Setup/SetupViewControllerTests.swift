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

    func testSetupViewControllerInPortaitMode() {
       // record = true
        combos(Language.languages, SnapshotTestingDevices.portrait).forEach { language, device in
            testWithEnvironment(language: language, block: {
                let vc = SetupViewController()
                assertSnapshot(matching: vc, as: .image(on: device))
                assertSnapshot(matching: vc, as: .recursiveDescription(on: device))
            })
        }
    }

    func testSetupViewControllerInLandscapeMode() {
        // record = true
        combos(Language.languages, SnapshotTestingDevices.landscape).forEach { language, device in
            testWithEnvironment(language: language, block: {
                let vc = SetupViewController()
                assertSnapshot(matching: vc, as: .image(on: device))
                assertSnapshot(matching: vc, as: .recursiveDescription(on: device))
            })
        }
    }
}
