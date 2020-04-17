//
//  LoadingPlugin.swift
//  WisedomSong
//
//  Created by droog on 2018/8/16.
//  Copyright © 2018年 田向阳. All rights reserved.
//

import UIKit
import Moya

class LoadingPlugin: PluginType {

    /// Called immediately before a request is sent over the network (or stubbed).
    func willSend(_ request: RequestType, target: TargetType) {
        if let target = target as? NetTargetType, target.isLoading {
            Print("isloading")
            safeAsync {
                HUDHelper.showLoadingHud(inView: SystemBridge.topViewController()?.view)
            }
        }
    }
    
    /// Called after a response has been received, but before the MoyaProvider has invoked its completion handler.
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if let target = target as? NetTargetType, target.isLoading {
            Print("isloading")
            safeAsync {
                HUDHelper.hideLoadingHud(inView: SystemBridge.topViewController()?.view)
            }
        }
    }
}
