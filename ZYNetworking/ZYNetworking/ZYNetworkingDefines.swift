//
//  ZYNetworkingDefines.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/5/16.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import Foundation

public let kZYUserTokenInvalidNotification: String = "kZYUserTokenInvalidNotification"
public let kZYUserTokenIllegalNotification: String = "kZYUserTokenIllegalNotification"

public let kZYUserTokenNotificationUserInfoKeyManagerToContinue: String = "kZYUserTokenNotificationUserInfoKeyManagerToContinue"
public let kZYAPIBaseManagerRequestId: String = "kZYAPIBaseManagerRequestId"


public enum ZYServiceAPIEnvironment {
    case develop
    case release
}

public enum ZYAPIManagerCachePolicy {
    case noCache
    case memory
    case disk
}

public enum ZYAPIManagerRequestType {
    case post
    case get
}

public enum ZYAPIManagerErrorType {
    case needAccessToken // 需要重新刷新accessToken
    case needLogin       // 需要登陆
    case defaultStatus   // 没有产生过API请求，这个是manager的默认状态。
    case loginCanceled   // 调用API需要登陆态，弹出登陆页面之后用户取消登陆了
    case success         // API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    case noContent       // API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    case paramsError     // 参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    case timeOut         // 请求超时。ZYAPIProxy设置的是20秒超时，具体超时时间的设置请自己去看ZYAPIProxy的相关代码。
    case noNetWork       // 网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
    case canceled        // 取消请求
    case noError         // 无错误
    case downGrade       // APIManager被降级了
}

// MARK: - ZYBaseAPIManagerProtocol & ZXPageAPIManagerProtocol
public protocol ZYBaseAPIManagerProtocol: class {
    
    var path: String { get }
    var apiVersion: String { get }
    
    // optional
    func reformParams(params: Dictionary<String, Any>?) -> Dictionary<String, Any>?
    var method: ZYAPIManagerRequestType { get }
    var isAuth: Bool { get }
    var serviceIdentifier: String { get }
    
}


public extension ZYBaseAPIManagerProtocol {
    
    func reformParams(params: Dictionary<String, Any>?) -> Dictionary<String, Any>? {
        return params
    }
    
    var method: ZYAPIManagerRequestType {
        return .get
    }
    
    var isAuth: Bool {
        return true
    }

    var serviceIdentifier: String {
        return "test"
    }
}


public protocol ZYPageAPIManagerProtocol: ZYBaseAPIManagerProtocol {
    
    var keyOfResult: String { get }
    
    var keyOfResultItemId: String { get }
}


public extension ZYPageAPIManagerProtocol {
    
    var keyOfResultItemId: String {
        return "id";
    }
    
}

// MARK: - ZYAPIManagerValidator
public protocol ZYAPIManagerValidator: class {
    
    func manager(_ manager: ZYBaseAPIManager!, isCorrectWithCallBackData data: Dictionary<String, Any>?) -> ZYAPIManagerErrorType
    
    func manager(_ manager: ZYBaseAPIManager!, isCorrectWithParamsData data: Dictionary<String, Any>?) -> ZYAPIManagerErrorType
    
}

// MARK: - ZYAPIManagerInterceptor
@objc public protocol ZYAPIManagerInterceptor: class {
    
    @objc optional func manager(_ manager: ZYBaseAPIManager!, beforePerformSuccessWith response: ZYURLResponse!) -> Bool
    @objc optional func manager(_ manager: ZYBaseAPIManager!, afterPerformSuccessWith response: ZYURLResponse!) -> Void
    
    @objc optional func manager(_ manager: ZYBaseAPIManager!, beforePerformFailWith response: ZYURLResponse!) -> Bool
    @objc optional func manager(_ manager: ZYBaseAPIManager!, afterPerformFailWith response: ZYURLResponse!) -> Void
    
    @objc optional func manager(_ manager: ZYBaseAPIManager!, shouldCallAPIWith params: Dictionary<String, Any>?) -> Bool
    @objc optional func manager(_ manager: ZYBaseAPIManager!, afterCallAPIWith params: Dictionary<String, Any>?) -> Void
    @objc optional func manager(_ manager: ZYBaseAPIManager!, didReceive response: ZYURLResponse?) -> Void
    
}


public protocol ZYAPIManagerCallBackDelegate: class {
    
    func managerCallAPIDidSuccess(_ manager: ZYBaseAPIManager!) -> Void
    func managerCallAPIDidFailed(_ manager: ZYBaseAPIManager!) -> Void
    
}


public protocol ReformerProtocol {
    func reformData(withManager manager: ZYBaseAPIManager!, data: Dictionary<String, Any>?) -> Any?
}


public protocol ZYBaseAPIManagerParamSource: class {
    
    func paramsforManager(_ manager: ZYBaseAPIManager!) -> Dictionary<String, Any>?
    
}
