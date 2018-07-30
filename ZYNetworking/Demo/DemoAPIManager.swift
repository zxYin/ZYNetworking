//
//  DemoAPIManager.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/7/29.
//  Copyright © 2018 殷子欣. All rights reserved.
//

import UIKit

class DemoAPIManager: ZYBaseAPIManager {

    required init() {
        super.init()
        self.paramSource = self
    }
    
}

extension DemoAPIManager: ZYBaseAPIManagerProtocol {
    
    var path: String {
        return "public/characters"
    }
    var apiVersion: String {
        return "1.0"
    }
    
    var serviceIdentifier: String {
        return ZYNetworkingDemoServiceIdentifier
    }
    
}

extension DemoAPIManager: ZYBaseAPIManagerParamSource {
    
    func paramsforManager(_ manager: ZYBaseAPIManager!) -> Dictionary<String, Any>? {
        return nil
    }
    
}
