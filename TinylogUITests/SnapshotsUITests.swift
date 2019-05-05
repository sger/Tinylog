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

        if app/*@START_MENU_TOKEN@*/.buttons["useiCloudButton"]/*[[".buttons[\"Later\"]",".buttons[\"useiCloudButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists {
            app/*@START_MENU_TOKEN@*/.buttons["useiCloudButton"]/*[[".buttons[\"Later\"]",".buttons[\"useiCloudButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }

        snapshot("02")
        app/*@START_MENU_TOKEN@*/.buttons["addListButton"]/*[[".otherElements[\"MyLists\"]",".buttons[\"plus\"]",".buttons[\"addListButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()

        snapshot("03")
        app.navigationBars["Add List"].buttons["Cancel"].tap()
        app.navigationBars["My Lists"]/*@START_MENU_TOKEN@*/.buttons["settingsButton"]/*[[".buttons[\"740 gear toolbar\"]",".buttons[\"settingsButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        snapshot("04")
        app.navigationBars["Settings"].buttons["Done"].tap()
    }
}
