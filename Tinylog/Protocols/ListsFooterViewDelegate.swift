//
//  ListsFooterViewDelegate.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/08/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

protocol ListsFooterViewDelegate: AnyObject {
    func listsFooterViewAddNewList(_ listsFooterView: ListsFooterView)
    func listsFooterViewDisplayArchives(_ listsFooterView: ListsFooterView)
}
