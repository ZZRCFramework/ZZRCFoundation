//
//  BundleExt.swift
//  UMICHAT
//
//  Created by droog on 2019/11/8.
//  Copyright © 2019 田向阳. All rights reserved.
//

import Foundation
public extension Bundle {
    
    static let LanguageTypeKey = "LanguageTypeKey"
    
    private static var bundle: Bundle?
    
    class func setLanguageType(type: LanguageType) {
        bundle = nil
        UserDefaults.standard.set(type.rawValue, forKey: LanguageTypeKey)
        UserDefaults.standard.synchronize()
    }
    
    class func getLanguageType() -> LanguageType {
        if let languageInt = UserDefaults.standard.value(forKey: LanguageTypeKey) as? Int,  let type = LanguageType(rawValue: languageInt) {
            return type
        }
        return .LanguageSystem
    }
    
    class func localizedString(key: String, value: String? = nil) -> String {
        if let bundle = bundle {
            return bundle.localizedString(forKey: key, value: value, table: nil)
        }
        else {
            guard let path = Bundle.main.path(forResource: getLanguage(), ofType: "lproj") else {
                Print("加载不到指定路径的本地化文件")
                return key
            }
            bundle = Bundle.init(path: path)
            let new_value: String? = bundle?.localizedString(forKey: key, value: value, table: nil) ?? nil
            return bundle?.localizedString(forKey: key, value: new_value, table: nil) ?? key
        }
    }
    
    class func getLanguage() -> String {
        if let languageInt = UserDefaults.standard.value(forKey: LanguageTypeKey) as? Int,  let type = LanguageType(rawValue: languageInt) {
            var language = "zh-Hans"
            switch type {
            case .LanguageSystem:
                language = Locale.preferredLanguages.first ?? "zh"
                if language.hasPrefix("en") {
                    language = "en"
                }
                else {
                    language = "zh-Hans"
                }
                break
            case .LanguageChineseSimplified:
                language = "zh-Hans"
                break
            case .LanguageEnglish:
                language = "en"
                break
            }
            return language
        }
        else {
            var language = "zh-Hans"
            language = Locale.preferredLanguages.first ?? "zh"
            if language.hasPrefix("en") {
                language = "en"
            }
            else {
                language = "zh-Hans"
            }
            return language
        }
    }
}


public enum LanguageType: Int {
    //跟随系统语言，默认
    case  LanguageSystem = 1
    //中文简体
    case LanguageChineseSimplified = 2
    //英文
    case LanguageEnglish = 3
}
