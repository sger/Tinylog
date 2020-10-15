//
//  MenuColorsViewModel.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 11/10/20.
//  Copyright © 2020 Spiros Gerokostas. All rights reserved.
//

import Foundation

struct MenuColorsViewModel {

    private(set) var index: Int = 0
    let colors: [String] = ["#6a6de2", "#008efe", "#fe4565", "#ffa600", "#50de72", "#ffd401"]

    mutating func configure(list: TLIList?) {
        guard let list = list else {
            return
        }
        if let color = list.color {
            index = findIndexByColor(color)
        }
    }

    private func findIndexByColor(_ color: String) -> Int {
        colors.indexes(of: color).first ?? 0
    }
}
