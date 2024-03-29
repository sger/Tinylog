//
//  AddListViewControllerDelegate.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

protocol AddListViewControllerDelegate: AnyObject {
    func addListViewController(_ viewController: AddListViewController, didSucceedWithList list: TLIList)
    func addListViewControllerDismissed(_ viewController: AddListViewController)
}
