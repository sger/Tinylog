//
//  TLITag.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import Foundation
import CoreData

class TLITag: NSManagedObject {

    override func awakeFromInsert() {
        super.awakeFromInsert()

        if self.uniqueIdentifier == nil {
            self.uniqueIdentifier = ProcessInfo.processInfo.globallyUniqueString
        }
    }

    class func existing(_ name: NSString, context: NSManagedObjectContext) -> TLITag? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Tag")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)

        do {
            let result: NSArray = try context.fetch(fetchRequest) as NSArray

            if result.lastObject != nil {
                return result.lastObject as? TLITag
            } else {
                if let tag: TLITag = NSEntityDescription.insertNewObject(
                    forEntityName: "Tag",
                    into: context) as? TLITag {
                        tag.name = name as String
                        return tag
                }
            }
            return nil
        } catch let error as NSError {
            print("error : \(error.localizedDescription)")
            return nil
        }
    }
}
