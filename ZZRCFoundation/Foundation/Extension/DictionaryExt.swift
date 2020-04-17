//
//  DictionaryExt.swift
//  AFProject
//
//  Created by 田向阳 on 2019/8/2.
//  Copyright © 2019 田向阳. All rights reserved.
//

import Foundation
public extension Dictionary {
    func jsonString() -> String {
        do {
            let stringData = try JSONSerialization.data(withJSONObject: self as NSDictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let string = String(data: stringData, encoding: String.Encoding.utf8){
                return string
            }
        } catch _ {
            return ""
        }
        return ""
    }
    
    static func dicWithJson(_ jsonString: String) -> [String:Any]? {
        if let data = jsonString.data(using: String.Encoding.utf8) {
            let dic = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.init(rawValue: 0))
            return dic as? [String:Any]
        }
        return nil
    }
}
