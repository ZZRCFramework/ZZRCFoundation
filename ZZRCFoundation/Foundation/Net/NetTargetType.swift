//
//  DYTargetType.swift
//  WisedomSong
//
//  Created by droog on 2018/5/3.
//  Copyright © 2018年 田向阳. All rights reserved.
//

import Foundation
@_exported import Moya
import HandyJSON
import UIDeviceIdentifier

/// 定义 request的规范 基于moya rxswift
public protocol NetTargetType: TargetType {

    // 是否使用缓存策略
    var isCache: Bool { get }
    // 请求参数
    var params: [String:Any] { get }
    // 是否使用loading
    var isLoading: Bool { get }
    
    var isSign : Bool { get }
    
    var resultParams: [String:Any] { get }
    
    var timeoutInterval: TimeInterval { get }
    
    var plugins: [PluginType]? { get }
    
}


public extension NetTargetType {
    
    //是否使用loading
    var isLoading: Bool {
        return false
    }
    
    var headers: [String : String]? {
        let header: [String: String] = [:]
        return header
    }
    
    var sampleData: Data {
        return Data()
    }
    
    
    var method: Moya.Method {
        return .post
    }
    
    var timeoutInterval: TimeInterval {
        return 20
    }
    
    var task: Task {
        return .requestParameters(parameters: resultParams, encoding: URLEncoding.queryString)
    }
    
    var resultParams: [String:Any] {
        let aParams = self.params
        return aParams
    }
    
    var isSign: Bool {
        return false
    }
    
    var isCache: Bool {
        return false
    }
    
    var plugins: [PluginType]? {
        return nil
    }
}


