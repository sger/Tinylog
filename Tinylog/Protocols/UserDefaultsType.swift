//
//  UserDefaultsType.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 23/04/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

public protocol UserDefaultsType: AnyObject {

    func object(forKey defaultName: String) -> Any?
    func removeObject(forKey defaultName: String)
    func string(forKey defaultName: String) -> String?
    func dictionary(forKey defaultName: String) -> [String: Any]?
    func integer(forKey defaultName: String) -> Int
    func bool(forKey defaultName: String) -> Bool
    func double(forKey defaultName: String) -> Double
    func register(defaults registrationDictionary: [String: Any])

    func set(_ value: Any?, forKey defaultName: String)
    func set(_ value: Int, forKey defaultName: String)
    func set(_ value: Float, forKey defaultName: String)
    func set(_ value: Double, forKey defaultName: String)
    func set(_ value: Bool, forKey defaultName: String)
    func synchronize() -> Bool
}

extension UserDefaults: UserDefaultsType { }

internal class MockUserDefaults: UserDefaultsType {
    var data: [String: Any] = [:]

    func set(_ value: Bool, forKey defaultName: String) {
        self.data[defaultName] = value
    }

    func set(_ value: Int, forKey defaultName: String) {
        self.data[defaultName] = value
    }

    func set(_ value: Any?, forKey key: String) {
        self.data[key] = value
    }

    func bool(forKey defaultName: String) -> Bool {
        return self.data[defaultName] as? Bool ?? false
    }

    func dictionary(forKey key: String) -> [String: Any]? {
        return self.object(forKey: key) as? [String: Any]
    }

    func integer(forKey defaultName: String) -> Int {
        return self.data[defaultName] as? Int ?? 0
    }

    func object(forKey key: String) -> Any? {
        return self.data[key]
    }

    func string(forKey defaultName: String) -> String? {
        return self.data[defaultName] as? String
    }

    func removeObject(forKey defaultName: String) {
        self.set(nil, forKey: defaultName)
    }

    func synchronize() -> Bool {
        return true
    }

    func double(forKey defaultName: String) -> Double {
        return self.data[defaultName] as? Double ?? 0
    }

    func register(defaults registrationDictionary: [String: Any]) {}

    func set(_ value: Float, forKey defaultName: String) {
        self.data[defaultName] = value
    }

    func set(_ value: Double, forKey defaultName: String) {
        self.data[defaultName] = value
    }
}
