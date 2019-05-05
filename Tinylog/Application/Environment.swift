//
//  Environment.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 20/04/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

import Foundation

public struct Environment {

    public let language: Language
    public let userDefaults: UserDefaultsType

    static var stack: [Environment] = [Environment()]

    public init(language: Language = Language(languageStrings: Locale.preferredLanguages) ?? Language.en,
                userDefaults: UserDefaultsType = UserDefaults.standard) {
        self.language = language
        self.userDefaults = userDefaults
    }

    public static var current: Environment! {
        return stack.last
    }

    public static func updateLanguage(_ language: Language) {
        replaceCurrentEnvironment(language: language)
    }

    public static func pushEnvironment(_ env: Environment) {
        stack.append(env)
    }

    static func pushEnvironment(language: Language = Environment.current.language,
                                userDefaults: UserDefaultsType = Environment.current.userDefaults) {
        pushEnvironment(
            Environment(language: language,
                        userDefaults: userDefaults)
        )
    }

    public static func replaceCurrentEnvironment(_ env: Environment) {
        pushEnvironment(env)
        stack.remove(at: stack.count - 2)
    }

    public static func replaceCurrentEnvironment(language: Language = Environment.current.language,
                                                 userDefaults: UserDefaultsType = Environment.current.userDefaults) {
        replaceCurrentEnvironment(Environment(language: language,
                                              userDefaults: userDefaults))
    }

    @discardableResult
    public static func popEnvironment() -> Environment? {
        let last = stack.popLast()
        return last
    }
}
