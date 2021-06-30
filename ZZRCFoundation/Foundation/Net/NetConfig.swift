//
//  DYNetConfig.swift
//  Dayang
//
//  Created by 田向阳 on 2017/12/21.
//  Copyright © 2017年 田向阳. All rights reserved.
//
import HandyJSON

public enum ErrorCode: Int {
    case success = 0  //请求成功
    case tokenError = 9400  //请求成功
    case cache = 10086 //从缓存中读取
    case serverError = 500 //服务器内部错误
    case jsonError = 10087 //json解析失败
    case netError = -999 //网络错误
    case timeOut = 408  //请求超时

    // 业务的错误码 举个🌰
    case loginFaild = 9000 //登录失败
    
    func errorShow()->String{
        switch self {
        case .tokenError:
            return  "网络错误".localized
        default:
            return ""
        }
    }
}

public struct NetError: Error {
    let code: Int
    let message: String
    
    static func throwError(code: Int, message: String) -> NetError{
        return NetError(code: code, message: message)
    }
}

extension Error {
    var netError: NetError {
        return NetError.throwError(code: (self as NSError).code, message: (self as NSError).localizedDescription)
    }
}

public struct NetModel<ContentType>: HandyJSON { // <ContentType> 这个玩儿 要遵循 handyjson协议 或者里面的元素要遵循handyjson
    let code: Int
    let msg: String
    let body: ContentType?  // 鉴于网络请求返回的结构体 有可能是字典也有可能是数组 暂定值类型为 any
    public init() {
        self.code = 0
        self.msg = ""
        self.body = nil
    }
}

/// 网络回调的基本样式
///
/// - success: 成功的回调
/// - cache: 缓存获取
/// - failure: 失败的回调
public enum NetResult<Value, Error> {
    
    case success(Value)
    case cache(Value)
    case failure(Error)

    public init(value: Value) {
        self = .success(value)
    }
    
    public init(cache: Value) {
        self = .cache(cache)
    }
    
    public init(error: Error) {
        self = .failure(error)
    }
}

public let NetworkDomain = "Network.domain"
public let NetBodyKey = "body"
public let NetCodeKey = "code"
public let NetMessageKey = "msg"


typealias DataRequestCompleteBlock = (_ error: NetError,_ data: Data? ,_ result: [String:Any]?) -> (Void)

