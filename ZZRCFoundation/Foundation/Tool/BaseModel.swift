//
//  BaseModel.swift
//  ZZRCFoundation
//
//  Created by 田向阳 on 2020/4/17.
//  Copyright © 2020 田向阳. All rights reserved.
//

import UIKit
import HandyJSON
import WCDBSwift
open class BaseModel: NSObject,HandyJSON {
    open var isSelect = false

    open var cellType: AnyClass {
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
    open func mapping(mapper: HelpingMapper) {}
    open func didFinishMapping() {}
}

public extension TableDecodable where Self: BaseModel {
    static func createTable(isCommon: Bool = false){
        guard let dataBase = isCommon ? DataBaseManager.shared.commonDataBase : DataBaseManager.shared.userDataBase else { return }
        do {
            try dataBase.create(table: tableName(), of: Self.self)
        } catch {
            Print(error.localizedDescription)
        }
    }
}
