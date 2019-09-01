//
//  SetupCoordinatorTests.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 01/09/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import XCTest
@testable import Tinylog

class SetupCoordinatorTests: XCTestCase {

    private var routerMock: RouterMock!
    private var coordinator: Coordinator!
    
    override func setUp() {
        super.setUp()
        routerMock = RouterMock()
        coordinator = SetupCoordinator(router: routerMock)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCoordinator_whenStart_ResultIsTrue() {
        coordinator.start()
        let navigationController = routerMock.presentedViewController as! UINavigationController
        XCTAssertTrue(navigationController.viewControllers.first is SetupViewController)
        XCTAssertTrue(navigationController.viewControllers.count == 1)
    }
}
