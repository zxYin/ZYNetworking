//
//  CTMediator+ZYAppContext.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/7/20.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import Foundation
import CTMediator

extension CTMediator {
    
    public func zyNetworking_shouldPrintNetworkingLog() -> Bool {
        return (CTMediator.sharedInstance().performTarget("ZYAppContext", action: "shouldPrintNetworkingLog", params: nil, shouldCacheTarget: true) != nil)
    }
    
    public func zyNetworking_isReachable() -> Bool {
        return (CTMediator.sharedInstance().performTarget("ZYAppContext", action: "isReachable", params: nil, shouldCacheTarget: true) != nil)
    }
    
    public func zyNetworking_cacheResponseCountLimit() -> Int {
        return CTMediator.sharedInstance().performTarget("ZYAppContext", action: "cacheResponseCountLimit", params: nil, shouldCacheTarget: true) as! Int
    }
    
}
