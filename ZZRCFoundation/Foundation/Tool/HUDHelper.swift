//
//  WSHUDHelper.swift
//  WisedomSong
//
//  Created by 田向阳 on 2018/6/16.
//  Copyright © 2018年 田向阳. All rights reserved.
//

import UIKit

public class HUDHelper {

    private static let viewTag = 10000000
    private static let hudViewTag = 10000001
    private static let hudWidth = 60
    private static var loadingView: UIView?
    
    class func showLoadingHud(text: String? = nil , inView: UIView?) {
        hideLoadingHud(inView: inView)
        guard let inView = inView else {
            return
        }
        let view = UIView()
        view.tag = hudViewTag
        view.frame = inView.bounds
        inView.addSubview(view)
        view.pleaseWait()
        HUDHelper.loadingView = inView
    }

    class func hideLoadingHud(inView: UIView?) {
        guard let inView = inView else {
            return
        }
        if let hud = HUDHelper.loadingView?.viewWithTag(hudViewTag) {
            hud.removeFromSuperview()
            hud.clearAllNotice()
            HUDHelper.loadingView = nil
        }
        inView.clearAllNotice()
    }
    
    class func showHUD(text: String ,inView: UIView?) {
        guard inView != nil else {
            return
        }
        inView?.noticeOnlyText(text)
    }
    
    class func showTopHUD(text: String,inView: UIView?) {
        inView?.noticeTop(text)
    }
}
