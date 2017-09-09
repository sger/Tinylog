//
//  TLINotification+CoreDataProperties.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TLINotification {

    @NSManaged var added: NSNumber?
    @NSManaged var createdAt: Date?
    @NSManaged var displayText: String?
    @NSManaged var fireDate: Date?
    @NSManaged var uniqueIdentifier: String?
    @NSManaged var updatedAt: Date?
    @NSManaged var task: TLITask?

}
