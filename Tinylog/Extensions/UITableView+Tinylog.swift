//
//  UITableView+Tinylog.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 24/05/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import UIKit

// swiftlint:disable force_cast
extension UITableView {
    func dequeue<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath)
        return cell as! T
    }
}
