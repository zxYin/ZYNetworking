//
//  DemoAppContext.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/7/29.
//  Copyright © 2018 殷子欣. All rights reserved.
//

import UIKit

class Target_ZYAppContext: NSObject {

    @objc public func Action_shouldPrintNetworkingLog(params: Dictionary<String, Any>?) -> Bool {
        return true
    }
    
    @objc public func Action_isReachable(params: Dictionary<String, Any>?) -> Bool {
        return true
    }
    
    @objc public func Action_cacheResponseCountLimit(params: Dictionary<String, Any>?) -> Int {
        return 2
    }
}
