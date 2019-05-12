//
//  ReachabilityManager.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 12/05/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import Reachability

final class ReachabilityManager {
    
    static let instance = ReachabilityManager()
    
    var reachability: Reachability!
    
    private init() {
        print("Initialize Reachability")
        reachability = Reachability()
        try! reachability.startNotifier()
    }
}
