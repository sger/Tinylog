//
//  LocalizedStringTests.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 20/04/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import XCTest
@testable import Tinylog

class LocalizedStringTests: XCTestCase {

    func testGerman() {

        testWithEnvironment(language: .de) {

            let str = localizedString(key: "My_Lists")
            let str2 = localizedString(key: "Update_lists")

            let wantedString = String(format: str2, "10:00")

            XCTAssertEqual("Meine Listen", str)
            XCTAssertEqual("Letzte Aktualisierung 10:00", wantedString)
        }
    }

}
