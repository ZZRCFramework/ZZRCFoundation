//
//  ViewController.swift
//  ZZRCFoundation
//
//  Created by 田向阳 on 2020/4/17.
//  Copyright © 2020 田向阳. All rights reserved.
//

import UIKit
import WCDBSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let provinces = Province.getAllAddress()
        
        Print(provinces[10])
    }
}

