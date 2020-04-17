//
//  ArrayExt.swift
//  AFProject
//
//  Created by 田向阳 on 2019/8/2.
//  Copyright © 2019 田向阳. All rights reserved.
//

import Foundation

public extension Array {
    ///JsonStr
    func jsonString() -> String {
        var result:String = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                result = JSONString
            }
            
        } catch {
            result = ""
        }
        return result
    }
    
    static func arrayWithJson(_ jsonString: String) -> [[String:Any]]? {
        if let data = jsonString.data(using: String.Encoding.utf8) {
            let dic = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.init(rawValue: 0))
            return dic as? [[String:Any]]
        }
        return nil
    }
    
    /// 获取数组中指定索引的值
    ///
    /// - Parameter index: 索引
    /// - Returns: 对象
    func safeObjectAtIndex(index: Int) -> Element? {
        if index < self.count && index >= 0 {
            return self[index]
        }
        return nil
    }
}
