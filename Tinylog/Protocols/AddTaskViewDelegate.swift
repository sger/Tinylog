//
//  AddTaskViewDelegate.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

protocol AddTaskViewDelegate: class {

    func addTaskViewDidBeginEditing(_ addTaskView: AddTaskView)
    func addTaskViewDidEndEditing(_ addTaskView: AddTaskView)
    func addTaskView(_ addTaskView: AddTaskView, title: String)
}
