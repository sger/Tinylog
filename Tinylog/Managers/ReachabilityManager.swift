//
//  ReachabilityManager.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 12/05/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import Reachability

final class ReachabilityManager {

    /// Singleton
    static let instance = ReachabilityManager()

    /// Instance of the Reachability object
    var reachability: Reachability!

    private init() {
        reachability = try! Reachability()
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}
