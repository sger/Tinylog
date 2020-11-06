//
//  TaskTests.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 29/08/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import XCTest
@testable import Tinylog

class TaskTests: XCTestCase {

    private var coreDataContext: CoreDataContext?
    
    override func setUp() {
        super.setUp()
        coreDataContext = CoreDataContext(model: "Tinylog", memory: true)
    }
    
    override func tearDown() {
        coreDataContext = nil
        super.tearDown()
    }

    func testTask_whenTasksAdded_shouldReturnNumberOfTotalUnarchivedTasks() throws {
        
        let coreDataContext = try XCTUnwrap(self.coreDataContext)
        
        let list = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                       into: coreDataContext.managedObjectContext) as? TLIList
        list?.title = "firstList"
        list?.color = "red"
        try? coreDataContext.managedObjectContext.save()
        
        
        let firstTask = NSEntityDescription.insertNewObject(forEntityName: "Task",
                                                            into: coreDataContext.managedObjectContext) as? TLITask
        firstTask?.displayLongText = "firstList"
        firstTask?.list = list
        
        let secondTask = NSEntityDescription.insertNewObject(forEntityName: "Task",
                                                             into: coreDataContext.managedObjectContext) as? TLITask
        secondTask?.displayLongText = "secondList"
        secondTask?.list = list
        
        try? coreDataContext.managedObjectContext.save()
        
        let tmpList = try XCTUnwrap(list)
        
        let num = TLITask.numberOfUnarchivedTasks(with: coreDataContext.managedObjectContext, list: tmpList)
        
        XCTAssertEqual(num, 2)
    }
}
