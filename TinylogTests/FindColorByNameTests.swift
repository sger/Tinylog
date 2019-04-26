//
//  FindColorByNameTests.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 21/04/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import XCTest
@testable import Tinylog

class FindColorByNameTests: XCTestCase {

    func testFindColorByName() {
        XCTAssertEqual(Utils.findColorByName("purple"), "#6a6de2")
        XCTAssertEqual(Utils.findColorByName("blue"), "#008efe")
        XCTAssertEqual(Utils.findColorByName("red"), "#fe4565")
        XCTAssertEqual(Utils.findColorByName("orange"), "#ffa600")
        XCTAssertEqual(Utils.findColorByName("green"), "#50de72")
        XCTAssertEqual(Utils.findColorByName("yellow"), "#ffd401")
    }
}
