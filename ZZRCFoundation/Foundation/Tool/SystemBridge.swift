//
//  WSSystemBridge.swift
//  WisedomSong
//
//  Created by droog on 2018/7/23.
//  Copyright © 2018年 田向阳. All rights reserved.
//

import Foundation
import UIKit

public struct SystemBridge {
    
    // 根据某个URL跳转 (适配到iOS10)
    public static func jumpToSystemSetting(url: String) {
        let sysUrl: URL = URL(string: url)!
        if UIApplication.shared.canOpenURL(sysUrl) {
            UIApplication.shared.open(sysUrl, options: [:], completionHandler: nil)
        }
    }
    
    public static func callPhone(at: String) {
        jumpToSystemSetting(url: "tel://\(at)")
    }
    
    public static func jumpToSystemSetting(){
        jumpToSystemSetting(url: UIApplication.openSettingsURLString)
    }
    
    // 是否开启远程通知
    public static func isOpenRemoteNotification() -> Bool {
        return UIApplication.shared.isRegisteredForRemoteNotifications
    }
    
    
    /// 跳转到商店
    /// - Parameter appid: 应用在APPConnect上的的ID
    public static func jumpToScore(_ appid: String) {
        let metalkAppStoreUrl: String = String(format: "https://itunes.apple.com/app/id%@?mt=8", appid)
        jumpToSystemSetting(url: metalkAppStoreUrl)
    }
    
    // 语言
    public static func language() -> String {
        let preferredLang = Bundle.getLanguage()
        switch String(describing: preferredLang) {
        case "en-US", "en-CN":
            return "en"//英文
        case "zh-Hans-US","zh-Hans-CN","zh-Hant-CN","zh-TW","zh-HK","zh-Hans":
            return "ch"//中文
        default:
            return "en"
        }
    }
    
    public static func isChinese() -> Bool{
        if language() == "en" {
            return false
        }
        return true
    }
    
    public static func appVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        return version as? String ?? ""
    }
    
    public static func bundleIdentifier() -> String {
        let identifier = Bundle.main.infoDictionary?["CFBundleIdentifier"]
        return identifier as? String ?? ""
    }
    
    //获取当前tabbar上的顶部的控制器
    public static func getTabBarTopController() -> UIViewController? {
        let vc = UIApplication.shared.keyWindow?.rootViewController
        let tabbarVC = vc?.children.last as? UITabBarController
        let selectNav = tabbarVC?.selectedViewController as? UINavigationController
        return selectNav?.topViewController
    }
    
    ///获取当前控制器
    public static func currentViewController() -> UIViewController?{
        // 注意：因为侧滑是加到rootViewController上作为子控制器的，所以first是menu的侧滑控制器，第二个也就是最后一个控制器才是tabBarVc
        var vc = UIApplication.shared.keyWindow?.rootViewController
        if vc?.children.last != nil {
            vc = vc?.children.last
        }
        if ((vc?.presentedViewController) != nil){
            if vc?.presentedViewController?.presentedViewController != nil {
                vc = (vc?.presentedViewController?.presentedViewController)!
            }else{
                if let nav = vc?.presentedViewController as? UINavigationController {
                    vc = nav.topViewController
                }else{
                    vc =  vc?.presentedViewController
                }
            }
        }else if (vc?.isKind(of: UITabBarController.self)) == true {
            vc = ((vc as? UITabBarController)?.selectedViewController as? UINavigationController)?.topViewController
        }
        else if (vc?.isKind(of: UINavigationController.self)) == true {
            vc = (vc as? UINavigationController)?.visibleViewController
        }
        return vc
    }
    
    
    // 找到当前显示的window
    public static func getCurrentWindow() -> UIWindow? {
        // 找到当前显示的UIWindow
        var window: UIWindow? = UIApplication.shared.keyWindow
        /**
         window有一个属性：windowLevel
         当 windowLevel == UIWindowLevelNormal 的时候，表示这个window是当前屏幕正在显示的window
         */
        if window?.windowLevel != UIWindow.Level.normal {
            for tempWindow in UIApplication.shared.windows {
                if tempWindow.windowLevel == UIWindow.Level.normal {
                    window = tempWindow
                    break
                }
            }
        }
        return window
    }
    
    /* 递归找最上面的viewController */
    public static func topViewController() -> UIViewController? {
        return self.topViewControllerWithRootViewController(viewController: self.getCurrentWindow()?.rootViewController)
    }

    public static func tabBarController() -> UITabBarController? {
        return rootViewController()?.children.last as? UITabBarController
    }

    // MARK:- 获取rootViewController
    public static func rootViewController() -> UIViewController? {
        return ZZFoundation.keyWindow?.rootViewController
    }
    
    public static func topViewControllerWithRootViewController(viewController :UIViewController?) -> UIViewController? {
        if viewController == nil {
            return nil
        }
        if viewController?.presentedViewController != nil {
            return self.topViewControllerWithRootViewController(viewController: viewController?.presentedViewController!)
        }
        else if viewController?.isKind(of: UITabBarController.self) == true {
            return self.topViewControllerWithRootViewController(viewController: (viewController as! UITabBarController).selectedViewController)
        }
        else if viewController?.isKind(of: UINavigationController.self) == true {
            return self.topViewControllerWithRootViewController(viewController: (viewController as! UINavigationController).visibleViewController)
        }
        else {
            return viewController
        }
    }
    
    public static func isASPackage() -> Bool{
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        if build.toInt() == 0{
            return false
        }
        return true
    }
}
