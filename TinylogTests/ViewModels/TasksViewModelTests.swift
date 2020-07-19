//
//  TasksViewModelTests.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 19/7/20.
//  Copyright © 2020 Spiros Gerokostas. All rights reserved.
//

import XCTest
@testable import Tinylog

class TasksViewModelTests: XCTestCase {

    private var coreDataManager: CoreDataManager?

    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager(model: "Tinylog", memory: true)
    }

    override func tearDown() {
        coreDataManager = nil
        super.tearDown()
    }

    func testTasksViewModel_whenListHasTasks_returnsFormattedListTasks() throws {
        let coreDataContext = try XCTUnwrap(coreDataManager)
        
        let list = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                       into: coreDataContext.managedObjectContext) as? TLIList
        list?.title = "My List"
        list?.position = 1
        list?.color = "#6a6de2"
        list?.createdAt = Date()
        try? coreDataContext.managedObjectContext.save()
        
        let firstTask = NSEntityDescription.insertNewObject(forEntityName: "Task",
                                                            into: coreDataContext.managedObjectContext) as? TLITask
        firstTask?.displayLongText = "first task"
        firstTask?.list = list
        
        let secondTask = NSEntityDescription.insertNewObject(forEntityName: "Task",
                                                             into: coreDataContext.managedObjectContext) as? TLITask
        secondTask?.displayLongText = "second task"
        secondTask?.list = list
        
        try? coreDataContext.managedObjectContext.save()

        let sut = TasksViewModel(managedObjectContext: coreDataContext.managedObjectContext)
                
        XCTAssertEqual(sut.getFormattedListTasks(with: list), "My List\n- first task\n- second task\n")
    }
    
    func testTasksViewModel_whenListHasNoTasks_returnsFormattedListTasks() throws {
        let coreDataContext = try XCTUnwrap(coreDataManager)
        
        let list = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                       into: coreDataContext.managedObjectContext) as? TLIList
        list?.title = "My List"
        list?.position = 1
        list?.color = "#6a6de2"
        list?.createdAt = Date()
        try? coreDataContext.managedObjectContext.save()
    
        let sut = TasksViewModel(managedObjectContext: coreDataContext.managedObjectContext)
                
        XCTAssertEqual(sut.getFormattedListTasks(with: list), "My List\n")
    }
    
    func testTasksViewModel_whenListIsNil_returnsNilString() throws {
        let coreDataContext = try XCTUnwrap(coreDataManager)
        let sut = TasksViewModel(managedObjectContext: coreDataContext.managedObjectContext)
        XCTAssertNil(sut.getFormattedListTasks(with: nil))
    }
}
