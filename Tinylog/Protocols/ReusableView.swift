//
//  ReusableView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 24/05/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableView { }
