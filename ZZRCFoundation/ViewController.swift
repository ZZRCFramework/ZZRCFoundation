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
        Person.createTable(isCommon: true)
    }
}

class Person: BaseModel,TableCodable {
    var userId = ""
      var nickName = ""
      var sex = 0
      var phone = ""
      var isLogin = false
      enum CodingKeys: String, CodingTableKey {
          typealias Root = Person
          static let objectRelationalMapping = TableBinding(CodingKeys.self)
          case userId
          case nickName
          case isLogin
          //        字段约束
          static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
              return [
                  userId: ColumnConstraintBinding(isPrimary: true),
              ]
          }
      }
}
