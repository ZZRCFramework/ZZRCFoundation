//
//  KeychainTool.swift
//
//  Created by 田向阳 on 2018/4/25.
//  Copyright © 2018年 田向阳. All rights reserved.
//

import UIKit
import KeychainAccess

private let kService = "com.zzrc.microFinance"
private let kAccount = "com.microFinance.deviceid"

public struct KeychainTool {

    //MARK: public func
    static func getDeviveID() -> String {
        if let deviceId = getDeviceIdFromSandBox() {
            return deviceId
        }
        if let deviceId = getDeviceIdFromKeychain() {
            return deviceId
        }
        return storeDeviceIdToKeychain()
    }
    
    //MARK: fileprivate func
    fileprivate static func storeDeviceIdToKeychain () -> String {
        let keychain = Keychain(service: kService)
        let deviceID = NSUUID().uuidString
        keychain[kAccount] = deviceID
        storeDeviceIdToSandbox(deviceID: deviceID)
        return deviceID
    }
    
    fileprivate static func storeDeviceIdToSandbox(deviceID: String) {
        UserDefaults.standard.setValue(deviceID, forKey: kAccount)
        UserDefaults.standard.synchronize()
    }
    
    fileprivate static func getDeviceIdFromKeychain()  -> String? {
        let items = Keychain(service: kService).allItems()
        let item = items.first
        if let deviceId = item?["value"] as? String{
            storeDeviceIdToSandbox(deviceID: deviceId)
            return deviceId;
        }
        return nil
    }
    
    fileprivate static func getDeviceIdFromSandBox()  -> String? {
        return UserDefaults.standard.string(forKey: kAccount)
    }
}
