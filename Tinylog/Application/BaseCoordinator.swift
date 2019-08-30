//
//  BaseCoordinator.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 26/08/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import Foundation

class BaseCoordinator: Coordinator {
    
    var children: [Coordinator] = []
    
    func start() {
        fatalError("Start method should be implemented.")
    }
    
    func add(_ coordinator: Coordinator) {
        guard !children.contains(where: { $0 === coordinator }) else {
            print("Failed to add coordinator \(coordinator) because it exists")
            return
        }
        
        children.append(coordinator)
    }
    
    func remove(_ coordinator: Coordinator?) {
        guard !children.isEmpty, let coordinator = coordinator else {
            print("Failed to remove coordinator")
            return
        }
        
        if let coordinator = coordinator as? BaseCoordinator, !coordinator.children.isEmpty {
            coordinator.children
                .filter({ $0 !== coordinator })
                .forEach({ coordinator.remove($0) })
        }
        
        for (index, element) in children.enumerated() where element === coordinator {
            children.remove(at: index)
            break
        }
    }
}
