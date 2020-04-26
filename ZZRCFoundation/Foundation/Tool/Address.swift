//
//  Address.swift
//  ZZRCFoundation
//
//  Created by 田向阳 on 2020/4/26.
//  Copyright © 2020 田向阳. All rights reserved.
//

import UIKit
import WCDBSwift

open class Address: BaseModel,TableCodable {
    var id = 0
    var province_id = 0
    var province_name = ""
    var city_id = 0
    var city_name = ""
    var county_id = 0
    var county_name = ""
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = Address
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case province_id
        case province_name
        case city_id
        case city_name
        case county_id
        case county_name
        case id
        //        字段约束
        public static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true),
            ]
        }
    }
    
//    public func saveToDB(){
//        let database = DataBaseManager.shared.commonDataBase
//        do {
//            try database?.insert(objects: self, intoTable: Address.tableName())
//
//        } catch {
//            Print(error)
//        }
//    }
//    
    
    /// 获取国家所有城市 一级列表
    public class func getAllAddress() -> [Address] {
        let commonDB = DataBaseManager.shared.commonDataBase
        do {
            let provinces: [Address] = try commonDB.getObjects(fromTable: Address.tableName())
            return provinces
        } catch {
            return [Address]()
        }
    }
}

open class Province: BaseModel,TableCodable {
    
    open var id = 0
    open var name = ""
    open var cityList = [City]()
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = Province
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case name
        case cityList
        case id
        //        字段约束
        public static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true),
            ]
        }
    }
    
//    public func saveToDB(){
//        let database = DataBaseManager.shared.commonDataBase
//        do {
//            try database?.insert(objects: self, intoTable: Province.tableName())
//
//        } catch {
//            Print(error)
//        }
//    }
    
    /// 获取三级列表
    public class func getAllAddress() -> [Province] {
        let commonDB = DataBaseManager.shared.commonDataBase
        do {
            let provinces: [Province] = try commonDB.getObjects(fromTable: Province.tableName())
            return provinces
        } catch {
            return [Province]()
        }
    }
}

open class City: BaseModel,ColumnJSONCodable {
    open var id = 0
    open var name = ""
    open var countryList = [Country]()
}

open class Country: BaseModel,ColumnJSONCodable {
    open var id = 0
    open var name = ""
}

//Address.createTable(isCommon: true)
//Province.createTable(isCommon: true)
//
//guard let commonDB = DataBaseManager.shared.commonDataBase else { return }
//do {
//    let provinces: [Province] = try commonDB.getObjects(fromTable: Province.tableName())
//    Print(provinces)
//
//    let addressModels: [Address] = try commonDB.getObjects(fromTable: Address.tableName())
//    var provinceIds = [(Int)]()
//    var provinces = [Province]()
//    //先筛选出省份
//    for obj in addressModels {
//        if !provinceIds.contains(obj.province_id) {
//            provinceIds.append(obj.province_id)
//            let pModel = Province()
//            pModel.id = obj.province_id
//            pModel.name = obj.province_name
//            provinces.append(pModel)
//        }
//    }
//
//    //查出某个省份下 城市
//    for pro in provinces {
//        let cityAddresses = addressModels.filter { (obj) -> Bool in
//            return pro.id == obj.province_id
//        }
//        var cityIds = [Int]()
//        var citys = [City]()
//
//        for obj in cityAddresses {
//            if !cityIds.contains(obj.city_id) {
//                cityIds.append(obj.city_id)
//                let city = City()
//                city.id = obj.city_id
//                city.name = obj.city_name
//                citys.append(city)
//            }
//        }
//        pro.cityList = citys
//
//        //查城市下的县
//        for city in citys {
//            var countryIds = [Int]()
//            var countrys = [Country]()
//            for obj in cityAddresses {
//                if !countryIds.contains(obj.county_id){
//                    countryIds.append(obj.county_id)
//                    let country = Country()
//                    country.id = obj.county_id
//                    country.name = obj.county_name
//                    countrys.append(country)
//                }
//            }
//            city.countryList = countrys
//        }
//        pro.saveToDB()
//    }
//
//    commonDB.close()
//} catch {
//    Print(error)
//}
