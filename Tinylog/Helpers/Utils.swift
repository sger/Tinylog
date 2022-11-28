//
//  Utils.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 22/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import Foundation

open class Utils {
    open class func delay(_ delay: Double, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure)
    }
    static func findColorByName(_ name: String) -> String {
        switch name {
        case "purple":
            return "#6a6de2"
        case "blue":
            return "#008efe"
        case "red":
            return "#fe4565"
        case "orange":
            return "#ffa600"
        case "green":
            return "#50de72"
        case "yellow":
            return "#ffd401"
        default:
            return ""
        }
    }
}

internal func combos<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
    return xs.flatMap { x in
        return ys.map { y in
            return (x, y)
        }
    }
}

internal func combos<A, B, C>(_ xs: [A], _ ys: [B], _ zs: [C]) -> [(A, B, C)] {
    return xs.flatMap { x in
        return ys.flatMap { y in
            return zs.map { z in
                return (x, y, z)
            }
        }
    }
}
