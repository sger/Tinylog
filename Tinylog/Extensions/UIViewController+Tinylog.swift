//
//  UIViewController+Tinylog.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/08/2017.
//  Copyright © 2017 Spiros Gerokostas. All rights reserved.
//

import UIKit

extension UIViewController {
    // swiftlint:disable force_unwrapping
    public var topDistance: CGFloat {
        if self.navigationController != nil && !self.navigationController!.navigationBar.isTranslucent {
            return 0
        } else {
            let barHeight = self.navigationController?.navigationBar.frame.height ?? 0
            let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) :
                UIApplication.shared.statusBarFrame.height
            return barHeight + statusBarHeight
        }
    }
}

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
