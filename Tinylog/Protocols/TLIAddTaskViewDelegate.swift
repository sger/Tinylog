//
//  TLIAddTaskViewDelegate.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

@objc protocol TLIAddTaskViewDelegate {
    @objc optional func addTaskViewDidBeginEditing(_ addTaskView: TLIAddTaskView)
    @objc optional func addTaskViewDidEndEditing(_ addTaskView: TLIAddTaskView)
    @objc optional func addTaskViewShouldHideTags(_ addTaskView: TLIAddTaskView)
    func addTaskView(_ addTaskView: TLIAddTaskView, title: NSString)
}
