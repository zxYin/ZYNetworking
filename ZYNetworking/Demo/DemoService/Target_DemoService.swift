//
//  Target_DemoService.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/7/29.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import Foundation

public let ZYNetworkingDemoServiceIdentifier: String = "DemoService"

class Target_DemoService: NSObject {
    
    @objc public func Action_DemoService(params: Dictionary<String, Any>?) -> DemoService {
        return DemoService.init()
    }
    
}
