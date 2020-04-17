//
//  DYNetwork.swift
//  WisedomSong
//
//  Created by 田向阳 on 2018/6/16.
//  Copyright © 2018年 田向阳. All rights reserved.
//

import UIKit
import Moya


struct Network<Type: NetTargetType> {
    public static func dyRequest(target: Type,_ complete: WSRequestCompleteBlock?) {
        if target.isCache {
            NetCache.getCache(request: target, complete: { (error, data, result) -> (Void) in
                if result != nil {
                    complete?(WSResult.init(cache: result!))
                }
            })
        }
        
        let requestTimeoutClosure = { (endpoint: Endpoint, done: @escaping MoyaProvider<Type>.RequestResultClosure) in
            do {
                var request = try endpoint.urlRequest()
                request.timeoutInterval = target.timeoutInterval
                done(.success(request))
            }catch{
                Print("error:\(error)")
            }
        }
        let provider = MoyaProvider<Type>(requestClosure: requestTimeoutClosure, plugins: [LoadingPlugin()])
        provider.request(target) { (result) in
            switch result {
            case let .success(moyaResponse):
                do {
                    guard let json =  try moyaResponse.mapJSON() as? [String:Any] else {
                        let aError = NSError(domain: DYNetworkDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : "json error"])
                        safeAsync {
                            complete?(WSResult.init(error: aError))
                        }
                        return}
                    var code = 0
                    if let codeString = json["code"] {
                        code = codeString as? Int ?? 0
                    }
                    if code == ErrorCode.success.rawValue {
                        safeAsync {
                            complete?(WSResult.init(value: json))
                        }
                        //加缓存
                        if target.isCache {
                            NetCache.store(request: target, data: moyaResponse.data)
                        }
                    }else{
                        var msg = "网络错误".localized
                        if let message = json["message"] {
                            msg = message as? String ?? "unknown error"
                        }
                        if let message = json["msg"] {
                            msg = message as? String ?? "unknown error"
                        }
                        if code == ErrorCode.tokenError.rawValue {
                            //token 失效  做退出登录操作
//                            LoginServer.loginOut()
//                            LoginServer.shared.imManager?.configureSocketError(error: .tokenError)
                        }
                        let error = NSError(domain: DYNetworkDomain, code: code, userInfo: [NSLocalizedDescriptionKey : msg])
                        safeAsync {
                            complete?(WSResult.init(error: error))
                        }
                    }
                    Print("url:\(target.baseURL.absoluteString + target.path) \n params:\(target.resultParams) \n response:\(json)\n header:\(String(describing: target.headers))")
                }catch{
                    //json 解析失败
                    safeAsync {
                        complete?(WSResult.init(error: error as NSError))
                    }
                    Print("URL:\(target.baseURL.absoluteString + target.path)\n params:\(target.resultParams) \n error:\(error)")
                }
                break
            case let .failure(error):
                let aError = NSError(domain: DYNetworkDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : error.localizedDescription])
                safeAsync {
                    complete?(WSResult.init(error: aError))
                }
                Print("URL:\(target.baseURL.absoluteString + target.path)\n params:\(target.resultParams) \n error:\(error)")
                break
            }
        }
    }
    
}

