//
//  main.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 1/6/20.
//  Copyright © 2020 Spiros Gerokostas. All rights reserved.
//

import UIKit

let appDelegateClass: AnyClass = NSClassFromString("TestAppDelegate") ?? AppDelegate.self
UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(appDelegateClass))
