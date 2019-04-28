//
//  EditTaskViewControllerDelegate.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

@objc protocol EditTaskViewControllerDelegate {
    func onClose(_ editTaskViewController: EditTaskViewController, indexPath: IndexPath)
}
