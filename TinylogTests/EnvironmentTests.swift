//
//  AppEnvironmentTests.swift
//  AppEnvironmentTests
//
//  Created by Spiros Gerokostas on 24/03/2017.
//  Copyright © 2017 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable line_length
import XCTest
@testable import Tinylog

class EnvironmentTests: XCTestCase {

    func testUserDefaults() {
        let userDefaults = MockUserDefaults()
        userDefaults.set(17.0, forKey: "fontSize")
        Environment.pushEnvironment(language: .en, userDefaults: userDefaults)
        XCTAssertEqual(Environment.current.userDefaults.double(forKey: "fontSize"), 17.0)
    }
}
