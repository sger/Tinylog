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

final class ListsViewControllerTests: XCTestCase {

    var coreDataManager: CoreDataContext!

    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataContext(model: "Tinylog", memory: true)
    }

    override func tearDown() {
        super.tearDown()
        coreDataManager = nil
    }

    func testListViewControllerWithPalatinoFont() {
        let list = NSEntityDescription.insertNewObject(
            forEntityName: "List",
            into: coreDataManager.managedObjectContext) as? TLIList
        list?.title = "my list"
        list?.position = 1
        list?.color = "#6a6de2"
        list?.createdAt = Date()
        try! coreDataManager.managedObjectContext.save()

        let userDefaults = MockUserDefaults()
        userDefaults.set(21.0, forKey: EnvUserDefaults.fontSize)
        userDefaults.set(kTLIFontPalatinoKey, forKey: String(kTLIFontDefaultsKey))

        testWithEnvironment(language: .en, userDefaults: userDefaults, block: {

            let vc = ListsViewController(managedObjectContext: coreDataManager.managedObjectContext)
            
            assertSnapshot(matching: vc, as: .image)
        })
    }
}
