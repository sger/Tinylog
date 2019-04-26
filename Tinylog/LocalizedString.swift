//
//  LocalizedString.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 20/04/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

public func localizedString(key: String,
                            bundle: Bundle = Bundle.main,
                            env: Environment = Environment.current) -> String {
    
    let lprojName = lprojFileNameForLanguage(env.language)
        
    if let path = bundle.path(forResource: lprojName, ofType: "lproj"),
        let bundle = Bundle(path: path) {
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
    
    return ""
}

private func lprojFileNameForLanguage(_ language: Language) -> String {
    return language.rawValue == "en" ? "Base" : language.rawValue
}


/*
 extension Bundle: NSBundleType {
 public static func create(path: String) -> NSBundleType? {
 return Bundle(path: path)
 }
 }*/

/*
 let bundle: Bundle = .main
 // Try to load from language specific bundle
 if let path = bundle.path(forResource: "fr", ofType: "lproj"),
 let bundle = Bundle(path: path) {
 return bundle.localizedString(forKey: "Hello, World", value: nil)
 }
 // Load from Base bundle
 else if let path = bundle.path(forResource: LCLBaseBundle, ofType: "lproj"),
 let bundle = Bundle(path: path) {
 return bundle.localizedString(forKey: "Hello, World", value: nil)
 }*/
