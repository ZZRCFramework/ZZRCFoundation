//
//  KeychainTool.swift
//
//  Created by 田向阳 on 2018/4/25.
//  Copyright © 2018年 田向阳. All rights reserved.
//

import UIKit
import KeychainAccess

private let kService = "com.zzrc.microFinance"

public struct KeychainTool {
    /// 获取设备唯一ID 此ID是存储于钥匙串的 不能保证是唯一的，存在极端删除钥匙串的情况
    /// - Parameter account: 应用的bundleid 最好
    public static func getDeviveID(account:
        String = SystemBridge.bundleIdentifier()) -> String {
        if let deviceId = getDeviceIdFromSandBox(account: account) {
            return deviceId
        }
        if let deviceId = getDeviceIdFromKeychain(account: account) {
            return deviceId
        }
        return storeDeviceIdToKeychain(account: account)
    }
    
    //MARK: fileprivate func
    fileprivate static func storeDeviceIdToKeychain (account: String) -> String {
        let keychain = Keychain(service: kService)
        let deviceID = UUID().uuidString
        keychain[account] = deviceID
        storeDeviceIdToSandbox(deviceID: deviceID,account: account)
        return deviceID
    }
    
    fileprivate static func storeDeviceIdToSandbox(deviceID: String, account: String) {
        UserDefaults.standard.setValue(deviceID, forKey: account)
        UserDefaults.standard.synchronize()
    }
    
    fileprivate static func getDeviceIdFromKeychain(account: String)  -> String? {
        let items = Keychain(service: kService).allItems()
        let item = items.first
        if let deviceId = item?["value"] as? String{
            storeDeviceIdToSandbox(deviceID: deviceId,account: account)
            return deviceId
        }
        return nil
    }
    
    fileprivate static func getDeviceIdFromSandBox(account: String)  -> String? {
        return UserDefaults.standard.string(forKey: account)
    }
}
