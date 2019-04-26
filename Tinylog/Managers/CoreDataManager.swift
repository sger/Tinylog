//
//  CoreDataManager.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 19/04/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import Foundation

class CoreDataManager {
    
    private let model: String
    private let memory: Bool
    
    init(model: String, memory: Bool = false) {
        self.model = model
        self.memory = memory
    }
    
    var storeDirectoryURL: URL {
        // swiftlint:disable force_try
        return try! FileManager.default.url(for: .applicationSupportDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: true)
    }
    
    var storeURL: URL {
        return self.storeDirectoryURL.appendingPathComponent("store.sqlite")
    }
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        print(Bundle.main.bundleIdentifier ?? "")
        print(self.storeDirectoryURL)
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        print(urls[urls.endIndex-1])
        let modelURL = Bundle.main.url(forResource: self.model, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var storeCoordinator: NSPersistentStoreCoordinator = {
        try! FileManager.default.createDirectory(at: self.storeDirectoryURL,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let storeType = self.memory ? NSInMemoryStoreType : NSSQLiteStoreType
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        try! coordinator.addPersistentStore(ofType: storeType,
                                            configurationName: nil,
                                            at: self.storeURL,
                                            options: options)
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.storeCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    lazy var syncManagedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.storeCoordinator
        return context
    }()
}
