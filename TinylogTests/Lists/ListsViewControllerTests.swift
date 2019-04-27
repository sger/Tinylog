//
//  ListsViewControllerTests.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 19/04/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import XCTest
@testable import Tinylog
import SnapshotTesting

class ListsViewControllerTests: XCTestCase {

    var coreDataManager: CoreDataManager!

    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager(model: "Tinylog", memory: true)
    }

    override func tearDown() {
        super.tearDown()
        coreDataManager = nil
    }

    func testListsViewController() {

        let list = NSEntityDescription.insertNewObject(forEntityName: "List", into: coreDataManager.managedObjectContext) as! TLIList
        list.title = "hello world"
        list.position = 1
        list.color = "#6a6de2"
        list.createdAt = Date()
        try! coreDataManager.managedObjectContext.save()

        let vc = ListsViewController()
        vc.managedObjectContext = coreDataManager.managedObjectContext

        assertSnapshot(matching: vc, as: .image(on: .iPhoneX(.landscape)))
        assertSnapshot(matching: vc, as: .recursiveDescription(on: .iPhoneX(.landscape)))

        assertSnapshot(matching: vc, as: .image(on: .iPhoneX(.portrait)))
        assertSnapshot(matching: vc, as: .recursiveDescription(on: .iPhoneX(.portrait)))
    }

    func testListsViewController2() {

        let list = NSEntityDescription.insertNewObject(forEntityName: "List", into: coreDataManager.managedObjectContext) as! TLIList
        list.title = "hello world"
        list.position = 1
        list.color = "#6a6de2"
        list.createdAt = Date()
        try! coreDataManager.managedObjectContext.save()

        testWithEnvironment(language: .de, block: {

            let vc = ListsViewController()
            vc.managedObjectContext = coreDataManager.managedObjectContext

            assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
            assertSnapshot(matching: vc, as: .recursiveDescription(on: .iPhoneX(.portrait)))
        })
    }
    
    func testListViewControllerWithFont() {
        
        let list = NSEntityDescription.insertNewObject(forEntityName: "List", into: coreDataManager.managedObjectContext) as! TLIList
        list.title = "my list"
        list.position = 1
        list.color = "#6a6de2"
        list.createdAt = Date()
        try! coreDataManager.managedObjectContext.save()
        
        let userDefaults = MockUserDefaults()
        userDefaults.set(21.0, forKey: TLIUserDefaults.kFontSize)
        userDefaults.set(kTLIFontPalatinoKey, forKey: String(kTLIFontDefaultsKey))
        
        testWithEnvironment(language: .en, userDefaults: userDefaults, block: {
            
            let vc = ListsViewController()
            vc.managedObjectContext = coreDataManager.managedObjectContext
            
            assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
            assertSnapshot(matching: vc, as: .recursiveDescription(on: .iPhoneX(.portrait)))
        })
    }
}
