//
//  ArchivesViewControllerTests.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 12/05/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//


import XCTest
@testable import Tinylog
import SnapshotTesting

class ArchivesViewControllerTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
//        record = true
        coreDataManager = CoreDataManager(model: "Tinylog", memory: true)
    }
    
    override func tearDown() {
        super.tearDown()
        coreDataManager = nil
    }
    
    func testArchivesViewController() {
        
        let list = NSEntityDescription.insertNewObject(
            forEntityName: "List",
            into: coreDataManager.managedObjectContext) as? TLIList
        list?.title = "my list"
        list?.position = 1
        list?.color = "#6a6de2"
        list?.createdAt = Date()
        list?.archivedAt = Date()
        try! coreDataManager.managedObjectContext.save()
        
        let userDefaults = MockUserDefaults()
        userDefaults.set(21.0, forKey: EnvUserDefaults.fontSize)
        userDefaults.set(kTLIFontSanFranciscoKey, forKey: String(kTLIFontDefaultsKey))
        
        testWithEnvironment(language: .en, userDefaults: userDefaults, block: {
            
            let vc = ArchivesViewController(managedObjectContext: coreDataManager.managedObjectContext)
            
            assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
            assertSnapshot(matching: vc, as: .recursiveDescription(on: .iPhoneX(.portrait)))
        })
    }
}

