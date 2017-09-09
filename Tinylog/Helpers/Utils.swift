//
//  Utils.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 22/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import Foundation

open class Utils {
    open class func delay(_ delay: Double, closure:@escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure)
    }
}
