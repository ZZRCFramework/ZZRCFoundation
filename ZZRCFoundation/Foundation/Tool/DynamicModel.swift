//
//  BaseModel.swift
//  ZZRCFoundation
//
//  Created by 田向阳 on 2020/4/17.
//  Copyright © 2020 田向阳. All rights reserved.
//

import UIKit
import HandyJSON

public class DynamicModel: NSObject,HandyJSON {
    var isSelect = false

    var cellType: AnyClass {
        return UITableViewCell.classForCoder()
    }
    
    override public var description: String {
        return self.toJSONString() ?? ""
    }
    
    public class func tableName() -> String {
        let className = self.className()
       return className.components(separatedBy: ".").last ?? ""
    }
    
    public class func className() -> String {
        return NSStringFromClass(self.classForCoder())
    }
    
    required override public init() {}
    public func mapping(mapper: HelpingMapper) {}
    public func didFinishMapping() {}
}
