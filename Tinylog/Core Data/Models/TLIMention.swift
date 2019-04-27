//
//  TLIMention.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import Foundation
import CoreData

class TLIMention: NSManagedObject {

    override func awakeFromInsert() {
        super.awakeFromInsert()

        if self.uniqueIdentifier == nil {
            self.uniqueIdentifier = ProcessInfo.processInfo.globallyUniqueString
        }
    }

    class func existing(_ name: NSString, context: NSManagedObjectContext) -> TLIMention? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Mention")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)

        do {
            let result: NSArray = try context.fetch(fetchRequest) as NSArray
            guard result.lastObject != nil else {
                return result.lastObject as? TLIMention
            }
            if let mention: TLIMention = NSEntityDescription.insertNewObject(
                forEntityName: "Mention",
                into: context) as? TLIMention {
                mention.name = name as String
                return mention
            }
            return nil
        } catch let error as NSError {
            print("error : \(error.localizedDescription)")
          return nil
        }
    }
}
