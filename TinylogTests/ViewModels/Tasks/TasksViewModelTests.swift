//
//  TasksViewModelTests.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 7/11/20.
//  Copyright © 2020 Spiros Gerokostas. All rights reserved.
//

import XCTest
@testable import Tinylog

class TasksViewModelTests: XCTestCase {
    
    private var coreDataContext: CoreDataContext?

    override func setUpWithError() throws {
        coreDataContext = CoreDataContext(model: "Tinylog", memory: true)
    }

    override func tearDownWithError() throws {
        coreDataContext = nil
    }

    func testViewModel_whenExportUnarchivedTasks_shouldReturnTasksAsString() throws {
        let coreDataContext = try XCTUnwrap(self.coreDataContext)
        let list = NSEntityDescription.insertNewObject(forEntityName: "List",
                                                       into: coreDataContext.managedObjectContext) as? TLIList
        list?.title = "My List"
        try? coreDataContext.managedObjectContext.save()
        
        let firstTask = NSEntityDescription.insertNewObject(forEntityName: "Task",
                                                            into: coreDataContext.managedObjectContext) as? TLITask
        firstTask?.displayLongText = "First Task"
        firstTask?.list = list
        
        try? coreDataContext.managedObjectContext.save()
        
        let secondTask = NSEntityDescription.insertNewObject(forEntityName: "Task",
                                                             into: coreDataContext.managedObjectContext) as? TLITask
        secondTask?.displayLongText = "Second Task"
        secondTask?.list = list
        
        try? coreDataContext.managedObjectContext.save()
        
        let tmpList = try XCTUnwrap(list)
        
        let expected = """
        My List
        - First Task
        - Second Task
        """
        
        let sut = TasksViewModel(managedObjectContext: coreDataContext.managedObjectContext)
        
        XCTAssertEqual(sut.exportUnarchivedTasks(with: tmpList), expected)
    }
}
