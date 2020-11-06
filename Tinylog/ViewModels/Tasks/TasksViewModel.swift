//
//  TasksViewModel.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 5/11/20.
//  Copyright © 2020 Spiros Gerokostas. All rights reserved.
//

import Foundation

final class TasksViewModel {
    
    private let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func exportUnarchivedTasks(with list: TLIList) -> String {
        let tasks = TLITask.fetchUnarchivedTasks(with: managedObjectContext, list)
        var output = ""
        
        output = output.appending("\(list.title ?? "")\n")
        
        tasks.forEach {
            output = output.appending("- \($0.displayLongText ?? "")\n")
        }
        
        return output
    }
}
