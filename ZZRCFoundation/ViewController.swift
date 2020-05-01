//
//  ViewController.swift
//  ZZRCFoundation
//
//  Created by 田向阳 on 2020/4/17.
//  Copyright © 2020 田向阳. All rights reserved.
//

import UIKit
import WCDBSwift

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let provinces = Province.getAllAddress()
        
        Print(provinces[10])
        
        Person.createTable(isCommon: true)
        let person = Person()
        do {
            try DataBaseManager.shared.commonDataBase.insert(objects: person, intoTable: Person.tableName())
        } catch {
            Print(error)
        }
    }
}

class Person: BaseModel,TableCodable {
    var userGid = ""
    var nickName = ""
    var sex = 0
    var phone = ""
    var isLogin = false
    var token = ""
    enum CodingKeys: String, CodingTableKey {
        typealias Root = Person
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case userGid
        case nickName
        case isLogin
        case token
        case phone
        case sex
        //        字段约束
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                userGid: ColumnConstraintBinding(isPrimary: true),
            ]
        }
    }
}
