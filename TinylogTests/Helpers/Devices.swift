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
                           ViewImageConfig.iPadPro12_9(.portrait),
                           ViewImageConfig.iPhone8(.portrait),
                           ViewImageConfig.iPhoneSe(.portrait)]

    static let landscape = [ViewImageConfig.iPhoneX(.landscape),
                            ViewImageConfig.iPhoneXsMax(.landscape),
                            ViewImageConfig.iPadPro12_9(.landscape),
                            ViewImageConfig.iPhone8(.landscape),
                            ViewImageConfig.iPhoneSe(.landscape)]
}
