//
//  SnapshotsUITests.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 28/07/2017.
//  Copyright © 2017 Spiros Gerokostas. All rights reserved.
//

import XCTest

class SnapshotsUITests: XCTestCase {

    override func setUp() {
        super.setUp()

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSnapshots() {

        let app = XCUIApplication()

        snapshot("01")
        
        if app.buttons["Later"].exists {
            app.buttons["Later"].tap()
        }
        
        snapshot("02")
        app.buttons["add list"].tap()
        snapshot("03")
        app.navigationBars["Add List"].buttons["Cancel"].tap()
        app.navigationBars["My Lists"].buttons["740 gear toolbar"].tap()
        snapshot("04")
        app.navigationBars["Settings"].buttons["Done"].tap()
    }
}
