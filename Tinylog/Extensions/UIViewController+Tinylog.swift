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

    public func addSearchController(with placeHolder: String,
                                    searchResultsUpdater: UISearchResultsUpdating,
                                    searchResultsController: UIViewController) {
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = searchResultsUpdater
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = placeHolder
        searchController.searchBar.autocapitalizationType = .none
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.tinylogTextColor]
        definesPresentationContext = true
    }
}

extension CoreDataTableViewController {
    func checkForEmptyResults() -> Bool {
        if let fetchedObjects = self.frc?.fetchedObjects {
            if fetchedObjects.isEmpty {
                return true
            }
        }
        return false
    }
}
