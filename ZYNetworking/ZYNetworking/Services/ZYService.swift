//
//  ZYService.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/7/18.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import Foundation
import CTMediator

public protocol ZYServiceProtocol {
    
    var apiEnvironment: ZYServiceAPIEnvironment { get }
    
    func requestWithParams(params: Dictionary<String, Any>?, path: String, requestType: ZYAPIManagerRequestType) -> NSURLRequest?
    
    func resultWithResponseData(responsedata data: Data?, response: URLResponse?, request: NSURLRequest?, error: Error?) -> Dictionary<String, Any>?
    
}

public class ZYServiceFactory: NSObject {
    
    static let sharedInstance = ZYServiceFactory()
    
    private override init() { }
    
    private var serviceStorage: Dictionary<String, ZYServiceProtocol> = Dictionary<String, ZYServiceProtocol>()
    
    public func service(withIdentifier identifier: String) -> ZYServiceProtocol {
        if serviceStorage[identifier] == nil {
            serviceStorage[identifier] = newService(withIdentifier: identifier)
        }
        return serviceStorage[identifier]!
    }
    
    private func newService(withIdentifier identifier: String) -> ZYServiceProtocol {
        return CTMediator.sharedInstance().performTarget(identifier, action: identifier, params: nil, shouldCacheTarget: false) as! ZYServiceProtocol
    }
}
