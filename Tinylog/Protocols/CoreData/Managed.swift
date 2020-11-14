//
//  Managed.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 11/11/20.
//  Copyright © 2020 Spiros Gerokostas. All rights reserved.
//

import CoreData

protocol Managed: AnyObject, NSFetchRequestResult {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
    static var defaultPredicate: NSPredicate { get }
}

extension Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] { return [] }
    static var defaultPredicate: NSPredicate { NSPredicate(value: true) }

    static var sortedFetchRequest: NSFetchRequest<Self> {
        let fetchRequest = NSFetchRequest<Self>(entityName: entityName)
        fetchRequest.sortDescriptors = defaultSortDescriptors
        return fetchRequest
    }

    static func sortedFetchRequest(with predicate: NSPredicate) -> NSFetchRequest<Self> {
        let fetchRequest = sortedFetchRequest
        fetchRequest.predicate = predicate
        return fetchRequest
    }

    static func fetchRequest(with sortDescriptors: [NSSortDescriptor]? = nil,
                             predicate: NSPredicate? = nil) -> NSFetchRequest<Self> {
        let fetchRequest = NSFetchRequest<Self>(entityName: entityName)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        return fetchRequest
    }
}

extension Managed where Self: NSManagedObject {
    static var entityName: String {
        guard let name = entity().name else {
            return ""
        }
        return name
    }

    static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        for object in context.registeredObjects where !object.isFault {
            guard let result = object as? Self, predicate.evaluate(with: result) else { continue }
            return result
        }
        return nil
    }

    static func fetch(in context: NSManagedObjectContext,
                      configurationBlock: (NSFetchRequest<Self>) -> Void = { _ in }) -> [Self] {
        let fetchRequest = NSFetchRequest<Self>(entityName: Self.entityName)
        configurationBlock(fetchRequest)
        return try! context.fetch(fetchRequest)
    }

    static func findOrCreate(in context: NSManagedObjectContext,
                             matching predicate: NSPredicate,
                             configure: (Self) -> Void) -> Self {
        guard let object = findOrFetch(in: context, matching: predicate) else {
            let newObject: Self = context.insertObject()
            configure(newObject)
            return newObject
        }
        return object
    }

    static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        guard let object = materializedObject(in: context, matching: predicate) else {
            return fetch(in: context) { request in
                request.predicate = predicate
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
            }.first
        }
        return object
    }
}

extension NSManagedObjectContext {
    func insertObject<A: NSManagedObject>() -> A where A: Managed {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName,
                                                            into: self) as? A else {
            fatalError("Wrong object type") }
        return obj
    }
}
