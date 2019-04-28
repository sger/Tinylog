//
//  AddTaskViewDelegate.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

@objc protocol AddTaskViewDelegate {
    @objc optional func addTaskViewDidBeginEditing(_ addTaskView: AddTaskView)
    @objc optional func addTaskViewDidEndEditing(_ addTaskView: AddTaskView)
    @objc optional func addTaskViewShouldHideTags(_ addTaskView: AddTaskView)
    func addTaskView(_ addTaskView: AddTaskView, title: NSString)
}
