//
//  TasksViewModel.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 19/7/20.
//  Copyright © 2020 Spiros Gerokostas. All rights reserved.
//

import Foundation
import CoreData

final class TasksViewModel {
    
    private let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    private func getListTasks(with list: TLIList?) -> [TLITask]? {
        guard let list = list else {
            return nil
        }
        
        do {
            let fetchRequest: NSFetchRequest<TLITask> = NSFetchRequest(entityName: "Task")
            let positionDescriptor: NSSortDescriptor = NSSortDescriptor(key: "position", ascending: false)
            let displayLongTextDescriptor: NSSortDescriptor = NSSortDescriptor(key: "displayLongText",
                                                                               ascending: true)
            fetchRequest.sortDescriptors = [positionDescriptor, displayLongTextDescriptor]
            fetchRequest.predicate = NSPredicate(format: "list = %@", list)
            fetchRequest.fetchBatchSize = 20
            return try managedObjectContext.fetch(fetchRequest) as [TLITask]
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func getFormattedListTasks(with list: TLIList?) -> String? {
        guard let list = list,
            let title = list.title,
            let tasks = getListTasks(with: list) else {
            return nil
        }
        
        var outputString: String = ""
        outputString = outputString.appending("\(title)\n")

        tasks.forEach { task in
            guard let displayLongText = task.displayLongText else {
                return
            }
            outputString = outputString.appending("- \(displayLongText)\n")
        }
        return outputString
    }
}
