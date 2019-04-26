//
//  XCTestCase+Environment.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 20/04/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import XCTest
@testable import Tinylog

extension XCTestCase {

    func testWithEnvironment(with env: Environment, block: () -> Void) {
        Environment.pushEnvironment(env)
        block()
        Environment.popEnvironment()
    }

    func testWithEnvironment(language: Language = Environment.current.language,
                             userDefaults: UserDefaultsType = Environment.current.userDefaults,
                             block: () -> Void) {
        testWithEnvironment(with: Environment(language: language, userDefaults: userDefaults),
                            block: block)
    }
}
