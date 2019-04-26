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
        
        let vc = TLIListsViewController()
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

            let vc = TLIListsViewController()
            vc.managedObjectContext = coreDataManager.managedObjectContext

            assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
            assertSnapshot(matching: vc, as: .recursiveDescription(on: .iPhoneX(.portrait)))
        })
        
//        combos(Language.languages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach { language, device in
//            testWithEnvironment(language: language) {
//
//                let vc = TLIListsViewController()
//                vc.managedObjectContext = coreDataManager.managedObjectContext
//                vc.viewWillAppear(true)
//
//                let (_, _) = traitControllers(device: device, orientation: .portrait, child: vc)
//
//                assertSnapshot(matching: vc, as: .image, named: "lang_\(language)_device_\(device)")
//            }
//        }
    }
}
