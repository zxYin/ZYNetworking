//
//  URLRequest+ZYNetworkingMethods.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/7/18.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import Foundation

public extension URLRequest {
    
//    // MARK:- RuntimeKey   动态绑属性
//    struct RuntimeKey {
//
//        static let kZYNetworkingActualRequestParams = UnsafeRawPointer.init(bitPattern: "kZYNetworkingActualRequestParams".hashValue)
//        static let kZYNetworkingOriginRequestParams = UnsafeRawPointer.init(bitPattern: "kZYNetworkingOriginRequestParams".hashValue)
//        static let kZYNetworkingRequestService = UnsafeRawPointer.init(bitPattern: "kZYNetworkingRequestService".hashValue)
//
//
//    }
//
//    var actualRequestParams: Dictionary<String, Any>? {
//        get {
//            return objc_getAssociatedObject(self, URLRequest.RuntimeKey.kZYNetworkingActualRequestParams!) as? Dictionary
//        }
//        set {
//            objc_setAssociatedObject(self, URLRequest.RuntimeKey.kZYNetworkingActualRequestParams!, newValue, .OBJC_ASSOCIATION_COPY)
//        }
//    }
//
//    var originRequestParams: Dictionary<String, Any>? {
//        get {
//            return objc_getAssociatedObject(self, URLRequest.RuntimeKey.kZYNetworkingOriginRequestParams!) as? Dictionary
//        }
//        set {
//            objc_setAssociatedObject(self, URLRequest.RuntimeKey.kZYNetworkingOriginRequestParams!, newValue, .OBJC_ASSOCIATION_COPY)
//        }
//    }
//
//    var service: ZYServiceProtocol? {
//        get {
//            let a = objc_getAssociatedObject(self, URLRequest.RuntimeKey.kZYNetworkingRequestService!)
//            return objc_getAssociatedObject(self, URLRequest.RuntimeKey.kZYNetworkingRequestService!) as? ZYServiceProtocol
//        }
//        set {
//            let a = newValue as? ZYServiceProtocol
//            objc_setAssociatedObject(self, URLRequest.RuntimeKey.kZYNetworkingRequestService!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            let b = objc_getAssociatedObject(self, URLRequest.RuntimeKey.kZYNetworkingRequestService!)
//            print("")
//        }
//    }
    
    private static var _service = [String: ZYServiceProtocol?]()
    private static var _actualRequestParams = [String: Dictionary<String, Any>?]()
    private static var _originRequestParams = [String: Dictionary<String, Any>?]()
    var service: ZYServiceProtocol? {
        get {
            let tempAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return URLRequest._service[tempAddress] ?? nil
        }
        set {
            let tempAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            URLRequest._service[tempAddress] = newValue
        }
    }
    
    var actualRequestParams: Dictionary<String, Any>? {
        get {
            let tempAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return URLRequest._actualRequestParams[tempAddress] ?? nil
        }
        set {
            let tempAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            URLRequest._actualRequestParams[tempAddress] = newValue
        }
    }
    
    var originRequestParams: Dictionary<String, Any>? {
        get {
            let tempAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return URLRequest._originRequestParams[tempAddress] ?? nil
        }
        set {
            let tempAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            URLRequest._originRequestParams[tempAddress] = newValue
        }
    }
}
