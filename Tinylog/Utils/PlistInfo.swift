//
//  PlistInfo.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 23/08/2017.
//  Copyright © 2017 Spiros Gerokostas. All rights reserved.
//

import UIKit

class PlistInfo: NSObject {
    static func versionInfo() -> String? {
        guard let infoDict = Bundle.main.infoDictionary else {
            return nil
        }
        if let build = infoDict["CFBundleVersion"],
            let version = infoDict["CFBundleShortVersionString"] {
            return "\(version) (\(build))"
        }
        return nil
    }
}
