//
//  UIColor+TinylogiOSAdditions.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

extension UIColor {

    convenience init(rgba: String) {
        var red: CGFloat   = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat  = 0.0
        var alpha: CGFloat = 1.0

        if rgba.hasPrefix("#") {
            let index = rgba.index(rgba.startIndex, offsetBy: 1)
            let hex = String(rgba[index...])
            let scanner = Scanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexInt64(&hexValue) {
                if hex.count == 6 {
                    red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)  / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF) / 255.0
                } else if hex.count == 8 {
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                } else {
                    print("invalid rgb string, length should be 7 or 9")
                }
            } else {
                print("scan hex error")
            }
        } else {
            print("invalid rgb string, missing '#' as prefix")
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    public static var tinylogNavigationBarColor: UIColor {
        return UIColor(hue: 0.0, saturation: 0.0, brightness: 0.98, alpha: 1.00)
    }

    public static var tinylogTableViewLineColor: UIColor {
        return UIColor(red: 224.0 / 255.0, green: 224.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0)
    }

    public static var tinylogTextColor: UIColor {
        return UIColor(red: 77.0 / 255.0, green: 77.0 / 255.0, blue: 77.0 / 255.0, alpha: 1.0)
    }

    public static var tinylogMainColor: UIColor {
        return UIColor(red: 43.0 / 255.0, green: 174.0 / 255.0, blue: 230.0 / 255.0, alpha: 1.0)
    }
    
    public static var tinylogDeleteRowAction: UIColor {
        return UIColor(red: 254.0 / 255.0, green: 69.0 / 255.0, blue: 101.0 / 255.0, alpha: 1.0)
    }

    public static var tinylogNumbersColor: UIColor {
        return UIColor(red: 76.0 / 255.0, green: 90.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0)
    }

    public static var tinylogNavigationBarLineColor: UIColor {
        return UIColor(red: 205.0 / 255.0, green: 205.0 / 255.0, blue: 205.0 / 255.0, alpha: 1.0)
    }

    public static var tinylogNavigationBarDarkColor: UIColor {
        return UIColor(red: 20.0 / 255.0, green: 21.0 / 255.0, blue: 24.0 / 255.0, alpha: 1.0)
    }

    public static var tinylogNavigationBarDayColor: UIColor {
        return UIColor(red: 243.0 / 255.0, green: 243.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0)
    }
    public static var tinylogLightGray: UIColor {
        return UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    }
    public static var tinylogLighterGray: UIColor {
        return UIColor(red: 244.0 / 255.0, green: 244.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
    }
    public static var tinylogEditRowAction: UIColor {
        return UIColor(red: 229.0 / 255.0, green: 230.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
    }
}
