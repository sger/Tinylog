//
//  TLITask.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import Foundation
import CoreData

class TLITask: NSManagedObject {

    override func awakeFromInsert() {
        super.awakeFromInsert()

        if self.uniqueIdentifier == nil {
            self.uniqueIdentifier = ProcessInfo.processInfo.globallyUniqueString
        }
    }
}

extension TLITask {
    static func fetchTasks(with context: NSManagedObjectContext, _ list: TLIList) -> [TLITask] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Task")
        let positionDescriptor = NSSortDescriptor(key: "position", ascending: false)
        fetchRequest.sortDescriptors = [positionDescriptor]
        fetchRequest.predicate = NSPredicate(format: "archivedAt = nil AND list = %@", list)
        fetchRequest.fetchBatchSize = 20

        do {
            return try context.fetch(fetchRequest) as? [TLITask] ?? []
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    static func fetchCompletedTasks(with context: NSManagedObjectContext, _ list: TLIList) -> [TLITask] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
            entityName: "Task")
        let positionDescriptor = NSSortDescriptor(key: "position", ascending: false)
        fetchRequest.sortDescriptors = [positionDescriptor]
        fetchRequest.predicate = NSPredicate(
            format: "archivedAt = nil AND completed = %@ AND list = %@",
            NSNumber(value: true as Bool), list)
        fetchRequest.fetchBatchSize = 20

        do {
            return try context.fetch(fetchRequest) as? [TLITask] ?? []
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    static func numberOfTasks(with context: NSManagedObjectContext, list: TLIList) -> Int {
        TLITask.fetchTasks(with: context, list).count
    }

    static func numberOfCompletedTasks(with context: NSManagedObjectContext, list: TLIList) -> Int {
        TLITask.fetchCompletedTasks(with: context, list).count
    }
}
