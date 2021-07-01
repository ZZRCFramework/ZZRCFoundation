//
//  DYNetwork.swift
//  WisedomSong
//
//  Created by 田向阳 on 2018/6/16.
//  Copyright © 2018年 田向阳. All rights reserved.
//

import UIKit
import Moya


struct Network<Type: NetTargetType,ResponseBody> {
    //返回参数 结构  {code: 0, message: this is a message, body:{}}
    public static func request(target: Type,_ complete: ((NetResult<NetModel<ResponseBody>, NetError>) -> (Void))?) {
        if target.isCache {
            NetCache.getCache(request: target, complete: { (error, data, result) -> (Void) in
                guard let netModel = NetModel<ResponseBody>.deserialize(from: result) else {return}
                complete?(NetResult(cache: netModel))
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
        let provider = MoyaProvider<Type>(requestClosure: requestTimeoutClosure, plugins: target.plugins ?? [])
        provider.request(target) { (result) in
            switch result {
            case let .success(moyaResponse):
               guard let json = try? moyaResponse.mapJSON() as? [String:Any],
                     let result = NetModel<ResponseBody>.deserialize(from: json) else {
                let aError = NetError.throwError(code: -1, message: "unknow response data format")
                safeAsync {
                    complete?(NetResult(error: aError))
                }
                Print("URL:\(target.baseURL.absoluteString + target.path)\n params:\(target.resultParams) \n error:\(aError) header: \(target.headers)" )
                return
               }
                if result.code == ErrorCode.success.rawValue {
                    safeAsync {
                        complete?(NetResult(value: result))
                    }
                    //加缓存
                    if target.isCache {
                        NetCache.store(request: target, data: moyaResponse.data)
                    }
                    Print("URL:\(target.baseURL.absoluteString + target.path)\n params:\(target.resultParams) \n  response: \(json) \n header: \(target.headers)")
                }else{
                    let error = NetError.throwError(code: result.code, message: result.msg)
                    safeAsync {
                        complete?(NetResult(error: error))
                    }
                    Print("URL:\(target.baseURL.absoluteString + target.path)\n params:\(target.resultParams) \n error:\(error) header: \(target.headers)")
                }
                break
            case let .failure(error):
                let aError = error.netError
                safeAsync {
                    complete?(NetResult.init(error: aError))
                }
                Print("URL:\(target.baseURL.absoluteString + target.path)\n params:\(target.resultParams) \n error:\(error)")
                break
            }
        }
    }
    
}

