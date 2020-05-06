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
    //返回参数 结构  {code: 0, message: this is a message, body:{}}
    public static func dyRequest(target: Type,_ complete: RequestCompleteBlock?) {
        if target.isCache {
            NetCache.getCache(request: target, complete: { (error, data, result) -> (Void) in
                if result != nil {
                    complete?(NetResult.init(cache: result!))
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
        let provider = MoyaProvider<Type>(requestClosure: requestTimeoutClosure, plugins: target.plugins)
        provider.request(target) { (result) in
            switch result {
            case let .success(moyaResponse):
                do {
                    guard let json =  try moyaResponse.mapJSON() as? [String:Any], let code = json[NetCodeKey] as? Int  else {
                        let aError = NSError(domain: NetworkDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : "json error"])
                        safeAsync {
                            complete?(NetResult.init(error: aError))
                        }
                        Print("url:\(target.baseURL.absoluteString + target.path) \n params:\(target.resultParams) \n response: null \n header:\(String(describing: target.headers))")
                        return
                    }
                    
                    if code == ErrorCode.success.rawValue {
                        safeAsync {
                            complete?(NetResult.init(value: json))
                        }
                        //加缓存
                        if target.isCache {
                            NetCache.store(request: target, data: moyaResponse.data)
                        }
                    }else{
                        var msg = "网络错误".localized
                        if let message = json[NetMessageKey] {
                            msg = message as? String ?? "unknown error"
                        }
                        let error = NSError(domain: NetworkDomain, code: code, userInfo: [NSLocalizedDescriptionKey : msg])
                        safeAsync {
                            complete?(NetResult.init(error: error))
                        }
                    }
                    Print("url:\(target.baseURL.absoluteString + target.path) \n params:\(target.resultParams) \n response:\(json)\n header:\(String(describing: target.headers))")
                }catch{
                    //json 解析失败
                    safeAsync {
                        complete?(NetResult.init(error: error as NSError))
                    }
                    Print("URL:\(target.baseURL.absoluteString + target.path)\n params:\(target.resultParams) \n error:\(error)")
                }
                break
            case let .failure(error):
                let aError = NSError(domain: NetworkDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : error.localizedDescription])
                safeAsync {
                    complete?(NetResult.init(error: aError))
                }
                Print("URL:\(target.baseURL.absoluteString + target.path)\n params:\(target.resultParams) \n error:\(error)")
                break
            }
        }
    }
    
}

