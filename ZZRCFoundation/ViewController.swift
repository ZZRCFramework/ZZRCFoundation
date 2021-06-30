//
//  ViewController.swift
//  ZZRCFoundation
//
//  Created by 田向阳 on 2020/4/17.
//  Copyright © 2020 田向阳. All rights reserved.
//

import UIKit
import WCDBSwift
import HandyJSON

struct User: HandyJSON {
    let sex: Int
    let userId: Int
    let userName: String
    let userStatus: Int
    init() {
        self.sex = 0
        self.userId = 1
        self.userName = ""
        self.userStatus = 0
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Network<Api, [User]>.request(target: .test) { result in
            switch result {
            case .cache(let dict), .success(let dict):
                Print(dict)
                dict.
                break
            case .failure(_):
                break
            }
        }
    }
}

enum Api: NetTargetType {
    case test
    
    var baseURL: URL {
        return URL(string: "http://localhost:37100")!
    }
    
    var path: String {
        return "/api/v1/config/test"
    }
    
    var params: [String : Any] {
        return ["id":123,"status":1,"a":1,"y":3]
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
