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

    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager(model: "Tinylog", memory: true)
    }
    
    override func tearDown() {
        coreDataManager = nil
        super.tearDown()
    }

    func teskTask_whenTasksAdded_numberOfTotalTasks() {
        
        let list = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                       into: coreDataManager.managedObjectContext) as? TLIList
        list?.title = "firstList"
        list?.color = "red"
        try! coreDataManager.managedObjectContext.save()
        
        
        let firstTask = NSEntityDescription.insertNewObject(forEntityName: "Task",
                                                            into: coreDataManager.managedObjectContext) as? TLITask
        firstTask?.displayLongText = "firstList"
        firstTask?.list = list
        
        let secondTask = NSEntityDescription.insertNewObject(forEntityName: "Task",
                                                             into: coreDataManager.managedObjectContext) as? TLITask
        secondTask?.displayLongText = "secondList"
        secondTask?.list = list
        
        try! coreDataManager.managedObjectContext.save()
        
        let num = TLITask.numOfTasks(with: coreDataManager.managedObjectContext, list!)
        
        XCTAssertEqual(num, 2)
    }
}
