//
//  Array+Tinylog.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 11/10/20.
//  Copyright © 2020 Spiros Gerokostas. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    func indexes(of element: Element) -> [Int] {
        enumerated()
        .filter { element == $0.element }
        .map { $0.offset }
    }
}
