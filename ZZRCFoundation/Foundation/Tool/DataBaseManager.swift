//
//  DataBaseManager.swift
//  ZZRCFoundation
//
//  Created by 田向阳 on 2020/4/17.
//  Copyright © 2020 田向阳. All rights reserved.
//

import Foundation
import WCDBSwift

open class DataBaseManager: NSObject {
    public static let shared = DataBaseManager()
    
    open var commonDataBase: Database
    open var userDataBase: Database?
    private var isEncrypt = false
    public convenience init(isEncrypt: Bool = false) {
        self.init()
        self.isEncrypt = isEncrypt
        self.initCommonDB()
    }
   
    override public init() {
        let commonDBPath = "common.db".documentPath()
        commonDataBase = Database(withPath: commonDBPath)
        Print(commonDBPath)
    }
    
    private func initCommonDB(){
        if isEncrypt {
            let key = DBConfigure.commonCipKey
            let data = key.data(using: String.Encoding.ascii)
            commonDataBase.setCipher(key: data,pageSize: 1024)
        }
    }
    //登陆成功时初始化当前用户的db
    public class func getUserDB(userId: String) -> Database?{
        guard let dataBase = DataBaseManager.shared.userDataBase else {
            let database = Database(withPath: "\(userId.md5()).db".documentPath())
            if DataBaseManager.shared.isEncrypt {
                let key = DBConfigure.commonCipKey
                let data = key.data(using: String.Encoding.ascii)
                database.setCipher(key: data,pageSize: 1024)
            }
            DataBaseManager.shared.userDataBase = database
            return database
        }
        return dataBase
    }
}

struct DBConfigure {
    public static let commonCipKey = "CommonCiperKey"
}
