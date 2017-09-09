//
//  UIViewController+Tinylog.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/08/2017.
//  Copyright © 2017 Spiros Gerokostas. All rights reserved.
//

import UIKit

extension TLICoreDataTableViewController {
    func checkForEmptyResults() -> Bool {
        if let fetchedObjects = self.frc?.fetchedObjects {
            if fetchedObjects.isEmpty {
                return true
            }
        }
        return false
    }
}
