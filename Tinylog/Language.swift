//
//  Language.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 20/04/2019.
//  Copyright © 2019 Spiros Gerokostas. All rights reserved.
//

public enum Language: String {
    case en
    case de
    
    public static let languages: [Language] = [.en, .de]
    
    public init?(with language: String) {
        switch language.lowercased() {
        case "en":
            self = .en
        case "de":
            self = .de
        default:
            return nil
        }
    }
    
    public init?(languageStrings languages: [String]) {
        guard let language = languages
            .lazy
            .map({ String($0.prefix(2)) })
            .compactMap(Language.init(with:))
            .first else {
                return nil
        }
        
        self = language
    }
}
