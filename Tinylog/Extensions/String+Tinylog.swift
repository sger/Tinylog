//
//  String+TinylogiOSAdditions.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

extension String {
    func length() -> Int {
        return self.characters.count
    }

    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func substring(_ location: Int, length: Int) -> String! {
        return (self as NSString).substring(with: NSRange(location: location, length: length))
    }

    subscript(index: Int) -> String! {
        get {
            return self.substring(index, length: 1)
        }
    }

    func location(_ other: String) -> Int {
        return (self as NSString).range(of: other).location
    }

    func contains(_ other: String) -> Bool {
        return (self as NSString).contains(other)
    }

    // http://stackoverflow.com/questions/6644004/how-to-check-if-nsstring-is-contains-a-numeric-value
    func isNumeric() -> Bool {
        return (self as NSString).rangeOfCharacter(
            from: CharacterSet.decimalDigits.inverted).location == NSNotFound
    }
}
