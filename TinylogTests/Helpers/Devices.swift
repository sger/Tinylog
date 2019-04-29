//
//  Devices.swift
//  TinylogTests
//
//  Created by Spiros Gerokostas on 28/04/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import SnapshotTesting

struct SnapshotTestingDevices {
    static let portrait = [ViewImageConfig.iPhoneX(.portrait),
                           ViewImageConfig.iPhoneXsMax(.portrait),
                           ViewImageConfig.iPadMini(.portrait),
                           ViewImageConfig.iPadPro10_5(.portrait),
                           ViewImageConfig.iPadPro11(.portrait),
                           ViewImageConfig.iPadPro12_9(.portrait),
                           ViewImageConfig.iPhone8(.portrait),
                           ViewImageConfig.iPhone8Plus(.portrait),
                           ViewImageConfig.iPhoneSe(.portrait),
                           ViewImageConfig.iPhoneXr(.portrait)]
    
    static let landscape = [ViewImageConfig.iPhoneX(.landscape),
                            ViewImageConfig.iPhoneXsMax(.landscape),
                            ViewImageConfig.iPadMini(.landscape),
                            ViewImageConfig.iPadPro10_5(.landscape),
                            ViewImageConfig.iPadPro11(.landscape),
                            ViewImageConfig.iPadPro12_9(.landscape),
                            ViewImageConfig.iPhone8(.landscape),
                            ViewImageConfig.iPhone8Plus(.landscape),
                            ViewImageConfig.iPhoneSe(.landscape),
                            ViewImageConfig.iPhoneXr(.landscape)]
}

