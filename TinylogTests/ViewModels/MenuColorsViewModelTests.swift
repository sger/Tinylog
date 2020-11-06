//
//  MenuColorsViewModelTests.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 11/10/20.
//  Copyright © 2020 Spiros Gerokostas. All rights reserved.
//

import XCTest
@testable import Tinylog

class MenuColorsViewModelTests: XCTestCase {
    
    private var coreDataManager: CoreDataContext?
    
    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataContext(model: "Tinylog", memory: true)
    }

    override func tearDown() {
        super.tearDown()
        coreDataManager = nil
    }

    func testViewModelColorIndex_whenColorIsNotNil_returnsFirstIndex() throws {
        let coreDataManager = try XCTUnwrap(self.coreDataManager)
        
        let list = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                       into: coreDataManager.managedObjectContext) as? TLIList
        list?.color = "#6a6de2"
        try? coreDataManager.managedObjectContext.save()
        
        var viewModel = MenuColorsViewModel()
        viewModel.configure(list: list)

        XCTAssertEqual(viewModel.index, 0)
    }
    
    func testViewModelColorIndex_whenColorIsNotNil_returnsSecondIndex() throws {
        let coreDataManager = try XCTUnwrap(self.coreDataManager)
        
        let list = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                       into: coreDataManager.managedObjectContext) as? TLIList
        list?.color = "#008efe"
        try? coreDataManager.managedObjectContext.save()
        
        var viewModel = MenuColorsViewModel()
        viewModel.configure(list: list)

        XCTAssertEqual(viewModel.index, 1)
    }
    
    func testViewModelColorIndex_whenColorIsNotNil_returnsThirdIndex() throws {
        let coreDataManager = try XCTUnwrap(self.coreDataManager)
        
        let list = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                       into: coreDataManager.managedObjectContext) as? TLIList
        list?.color = "#fe4565"
        try? coreDataManager.managedObjectContext.save()
        
        var viewModel = MenuColorsViewModel()
        viewModel.configure(list: list)

        XCTAssertEqual(viewModel.index, 2)
    }
    
    func testViewModelColorIndex_whenColorIsNotNil_returnsFourthIndex() throws {
        let coreDataManager = try XCTUnwrap(self.coreDataManager)
        
        let list = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                       into: coreDataManager.managedObjectContext) as? TLIList
        list?.color = "#ffa600"
        try? coreDataManager.managedObjectContext.save()
        
        var viewModel = MenuColorsViewModel()
        viewModel.configure(list: list)

        XCTAssertEqual(viewModel.index, 3)
    }
    
    func testViewModelColorIndex_whenColorIsNil_returnsZeroIndex() throws {
        let coreDataManager = try XCTUnwrap(self.coreDataManager)
        
        let list = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                       into: coreDataManager.managedObjectContext) as? TLIList
        try? coreDataManager.managedObjectContext.save()
        
        var viewModel = MenuColorsViewModel()
        viewModel.configure(list: list)

        XCTAssertEqual(viewModel.index, 0)
    }
}
