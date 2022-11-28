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

final class SetupViewControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    func testSetupViewControllerInPortaitMode() {
        testWithEnvironment(language: .en) {
            let viewController = SetupViewController()
            assertSnapshot(matching: viewController, as: .image)
        }
    }

    func testSetupViewControllerInLandscapeMode() {
        testWithEnvironment(language: .en) {
            let viewController = SetupViewController()
            assertSnapshot(matching: viewController, as: .image)
        }
    }
}
