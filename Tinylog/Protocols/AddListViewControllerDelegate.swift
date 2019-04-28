//
//  AddListViewControllerDelegate.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

@objc protocol AddListViewControllerDelegate {
    func onClose(_ addListViewController: AddListViewController, list: TLIList)
}
