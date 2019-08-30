//
//  BaseCoordinatorTests.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 26/08/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import XCTest
@testable import Tinylog

class BaseCoordinatorTests: XCTestCase {
    
    var sut: BaseCoordinator!

    override func setUp() {
        super.setUp()
        sut = BaseCoordinator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testBaseCoordinator_whenAddChildren_arrayIsNotEmpty() {
        sut.add(BaseCoordinatorStub())
        XCTAssertTrue(sut.children.count == 1)
        
        sut.add(BaseCoordinatorStub())
        
        XCTAssertTrue(sut.children.count == 2)
    }
    
    func testBaseCoordinator_whenAddChildren_uniqueCoordinators() {
        let coordinator = BaseCoordinatorStub()
        
        sut.add(coordinator)
        sut.add(coordinator)
        
        XCTAssertTrue(sut.children.count == 1, "Coordinator exists in children array")
    }

    func testBaseCoordinator_whenRemoveChildren_arrayIsEmpty() {
        let coordinator = BaseCoordinatorStub()
        sut.add(coordinator)
        
        XCTAssertTrue(sut.children.first is BaseCoordinator)
        
        sut.remove(coordinator)
        
        XCTAssertTrue(sut.children.isEmpty)
        
        sut.remove(coordinator)
        XCTAssertTrue(sut.children.isEmpty, "Failed to remove coordinator because it doesn't exists")
    }
}
