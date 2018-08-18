//
//  URLRequest+ZYNetworkingMethods.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/7/18.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import Foundation


public extension NSURLRequest {
    
    // MARK:- RuntimeKey   动态绑属性
    struct RuntimeKey {

        static let kZYNetworkingActualRequestParams = UnsafeRawPointer.init(bitPattern: "kZYNetworkingActualRequestParams".hashValue)
        static let kZYNetworkingOriginRequestParams = UnsafeRawPointer.init(bitPattern: "kZYNetworkingOriginRequestParams".hashValue)
        static let kZYNetworkingRequestService = UnsafeRawPointer.init(bitPattern: "kZYNetworkingRequestService".hashValue)


    }

    var actualRequestParams: Dictionary<String, Any>? {
        get {
            return objc_getAssociatedObject(self, NSURLRequest.RuntimeKey.kZYNetworkingActualRequestParams!) as? Dictionary
        }
        set {
            objc_setAssociatedObject(self, NSURLRequest.RuntimeKey.kZYNetworkingActualRequestParams!, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }

    var originRequestParams: Dictionary<String, Any>? {
        get {
            return objc_getAssociatedObject(self, NSURLRequest.RuntimeKey.kZYNetworkingOriginRequestParams!) as? Dictionary
        }
        set {
            objc_setAssociatedObject(self, NSURLRequest.RuntimeKey.kZYNetworkingOriginRequestParams!, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }

    var service: ZYServiceProtocol? {
        get {
            return objc_getAssociatedObject(self, NSURLRequest.RuntimeKey.kZYNetworkingRequestService!) as? ZYServiceProtocol
        }
        set {
            objc_setAssociatedObject(self, NSURLRequest.RuntimeKey.kZYNetworkingRequestService!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
