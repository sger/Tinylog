//
//  ListTests.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 19/04/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import XCTest
@testable import Tinylog

class ListTests: XCTestCase {

    var coreDataManager: CoreDataManager!

    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager(model: "Tinylog", memory: true)
    }

    override func tearDown() {
        super.tearDown()
        coreDataManager = nil
    }

    func testInsertNewList() {
        let list = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                       into: coreDataManager.managedObjectContext) as? TLIList
        list?.title = "test"
        try! coreDataManager.managedObjectContext.save()

        XCTAssertEqual(list?.title, "test")
    }

    func testLists() {
        let firstList = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                            into: coreDataManager.managedObjectContext) as? TLIList
        firstList?.title = "firstList"
        let secondList = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                             into: coreDataManager.managedObjectContext) as? TLIList
        secondList?.title = "secondList"
        try! coreDataManager.managedObjectContext.save()

        XCTAssertEqual(TLIList.lists(with: coreDataManager.managedObjectContext).count, 2)
    }

    func testFilterLists() {
        let firstList = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                            into: coreDataManager.managedObjectContext) as? TLIList
        firstList?.title = "firstList"
        firstList?.color = "red"
        let secondList = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                             into: coreDataManager.managedObjectContext) as? TLIList
        secondList?.title = "secondList"
        secondList?.color = "blue"
        try! coreDataManager.managedObjectContext.save()

        let fetchRequest = TLIList.filterLists(with: "firstList", color: "red")
        let lists = try! coreDataManager.managedObjectContext.fetch(fetchRequest) as? [TLIList]

        XCTAssertEqual(lists?.first?.title, "firstList")
        XCTAssertEqual(lists?.first?.color, "red")
    }
    
    func testFilterArchivedLists() {
        let firstList = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                            into: coreDataManager.managedObjectContext) as? TLIList
        firstList?.title = "firstList"
        firstList?.color = "red"
        firstList?.archivedAt = Date()
        let secondList = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                             into: coreDataManager.managedObjectContext) as? TLIList
        secondList?.title = "secondList"
        secondList?.color = "blue"
        try! coreDataManager.managedObjectContext.save()
        
        let fetchRequest = TLIList.filterArchivedLists(with: "firstList", color: "red")
        let lists = try! coreDataManager.managedObjectContext.fetch(fetchRequest) as? [TLIList]
        
        XCTAssertEqual(lists?.first?.title, "firstList")
        XCTAssertEqual(lists?.first?.color, "red")
        XCTAssertNotNil(lists?.first?.archivedAt)
    }
}
