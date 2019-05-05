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

    func testHelpTableViewControllerInPortaitMode() {
        // record = true
        combos(Language.languages, SnapshotTestingDevices.portrait).forEach { language, device in
            testWithEnvironment(language: language, block: {
                let vc = HelpTableViewController()
                assertSnapshot(matching: vc, as: .image(on: device))
                assertSnapshot(matching: vc, as: .recursiveDescription(on: device))
            })
        }
    }

    func testHelpTableViewControllerInLandscapeMode() {
        // record = true
        combos(Language.languages, SnapshotTestingDevices.landscape).forEach { language, device in
            testWithEnvironment(language: language, block: {
                let vc = HelpTableViewController()
                assertSnapshot(matching: vc, as: .image(on: device))
                assertSnapshot(matching: vc, as: .recursiveDescription(on: device))
            })
        }
    }
}
