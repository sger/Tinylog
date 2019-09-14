//
//  RouterTests.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 31/08/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import XCTest
@testable import Tinylog

class RouterTests: XCTestCase {
    
    private var coreDataManager: CoreDataManager!
    private var routerMock: RouterMock!
    private var listsViewController: ListsViewController!
    private var tasksViewController: TasksViewController!

    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager(model: "Tinylog", memory: true)
        
        let userDefaults = MockUserDefaults()
        userDefaults.set(21.0, forKey: EnvUserDefaults.fontSize)
        userDefaults.set(kTLIFontPalatinoKey, forKey: String(kTLIFontDefaultsKey))
        
        Environment.pushEnvironment(language: .en, userDefaults: userDefaults)
        
        routerMock = RouterMock()
        listsViewController = ListsViewController(managedObjectContext: coreDataManager.managedObjectContext)
        tasksViewController = TasksViewController(managedObjectContext: coreDataManager.managedObjectContext)
    }

    override func tearDown() {
        
        Environment.popEnvironment()
        coreDataManager = nil
        routerMock = nil
        listsViewController = nil
        super.tearDown()
    }

    func testRouter_whenPush_returnsTrue() {
        routerMock.push(listsViewController, animated: true)
        XCTAssertTrue(routerMock.viewControllers.first is ListsViewController)
    }
    
    func testRouter_whenPop_returnsTrue() {
        routerMock.push(listsViewController, animated: true)
        XCTAssertTrue(routerMock.viewControllers.last is ListsViewController)
        
        routerMock.push(tasksViewController, animated: true)
        XCTAssertTrue(routerMock.viewControllers.last is TasksViewController)
        
        routerMock.pop(animated: true)
        XCTAssertTrue(routerMock.viewControllers.last is ListsViewController)
    }
    
    func testRouter_whenPresent_returnsTrue() {
        routerMock.present(listsViewController, animated: true)
        XCTAssertTrue(routerMock.presentedViewController is ListsViewController)
    }
    
    func testRouter_whenDismiss_returnsTrue() {
        routerMock.present(listsViewController, animated: true)
        XCTAssertTrue(routerMock.presentedViewController is ListsViewController)
        routerMock.dismiss(animated: true)
        XCTAssertNil(routerMock.presentedViewController)
    }
}
