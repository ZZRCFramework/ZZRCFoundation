//
//  BaseStaticModel.swift
//  ZZRCFoundation
//
//  Created by 田向阳 on 2020/4/17.
//  Copyright © 2020 田向阳. All rights reserved.
//

import Foundation
import HandyJSON

struct StaticModel: HandyJSON {
    public func mapping(mapper: HelpingMapper) {}
    public func didFinishMapping() {}
}

public protocol BaseEnum: HandyJSONEnum {
   
}
