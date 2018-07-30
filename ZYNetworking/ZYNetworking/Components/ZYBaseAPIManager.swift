//
//  ZYBaseAPIManager.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/5/5.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import Foundation
import CTMediator


private let kZYNetworkingTimeoutSeconds: TimeInterval = 10.0
private let kZYCacheExpirationTimeDefault: TimeInterval = 60.0 * 5 // 默认缓存5分钟

public class ZYBaseAPIManager: NSObject {
    
    public weak var delegate: ZYAPIManagerCallBackDelegate?
    public weak var paramSource: ZYBaseAPIManagerParamSource?
    public weak var validator: ZYAPIManagerValidator?
    
    public weak var child: ZYBaseAPIManagerProtocol?
    
    public weak var interceptor: ZYAPIManagerInterceptor?
    
    // cache
    public var cachePolicy: ZYAPIManagerCachePolicy
    public var memoryCacheSecond: TimeInterval
    public var diskCacheSecond: TimeInterval
    public var shouldIgnoreCache: Bool = false // 默认为false
    
    // response
    public var response: ZYURLResponse!
    private(set) var errorType: ZYAPIManagerErrorType
    private(set) var errorMessage: String?
    
    // before loading
     var isReachable: Bool {
        get {
            let isReachability: Bool = CTMediator.sharedInstance().zyNetworking_isReachable()
            if (!isReachability) {
                errorType = .noNetWork
            }
            return isReachability
        }
    }
    
    private var _isLoading: Bool = false
    private(set) var isLoading: Bool {
        set {
          _isLoading = newValue
        }
        get {
            if requestIdList.count == 0 {
                return false
            }
            return _isLoading
        }
    }
    
    private var rawData: Any?
    private var requestIdList = [Int]()
    
    public var successBlock: ((ZYBaseAPIManager) -> Void)?
    public var failBlock: ((ZYBaseAPIManager) -> Void)?
    
    
    required override init() {

        errorType = .defaultStatus
        memoryCacheSecond = kZYCacheExpirationTimeDefault
        diskCacheSecond = kZYCacheExpirationTimeDefault
        cachePolicy = .noCache
        
        super.init()
        
        if self is ZYBaseAPIManagerProtocol {
            child = (self as! ZYBaseAPIManagerProtocol)
        } else {
            // 如果没有实现协议 强制闪退
            NSException(name: NSExceptionName(String(describing: type(of: self)) +  " init failed"), reason: "Subclass of ZYBaseAPIManager should implement <ZYBaseAPIManagerProtocol>", userInfo: nil).raise()
        }
    }
    
    deinit {
        cancelAllRequests()
        
    }

}


// MARK: - Public Methods
extension ZYBaseAPIManager {

    public func cancelAllRequests() {
        ZYAPIProxy.sharedInstance.cancelRequest(withRequestIdList: requestIdList)
        requestIdList.removeAll()
    }
    
    public func cancelRequest(withRequestId requestId: Int) {
        ZYAPIProxy.sharedInstance.cancelRequest(withRequestId: requestId)
        removeRequestId(withRequestId: requestId)
    }
    
    public func fetchDataWithReformer(reformer: ReformerProtocol?) -> Any? {
        return reformer?.reformData(withManager: self, data: rawData as? Dictionary<String, Any>) ?? rawData
    }
    
}


// MARK: - Calling API
extension ZYBaseAPIManager {
    
    public func loadData() -> Int {
        let params: Dictionary<String, Any>? = paramSource?.paramsforManager(self)
        let requestId: Int = loadData(withParams: params)
        
        return requestId
    }
    
    public func loadData(withParams params: Dictionary<String, Any>?) -> Int {
        
        let requestId: Int = 0
        let reformedParams: Dictionary<String, Any>? = reformParams(params)
        
        if let child = child {
            if shouldCallAPI(withParams: reformedParams) {
                let errorType: ZYAPIManagerErrorType = validator?.manager(self, isCorrectWithParamsData: reformedParams) ?? .noError
                if errorType == .noError {
                    
                    var response: ZYURLResponse?
                    
                    // 先检查一下是否有内存缓存
                    if cachePolicy == .memory && shouldIgnoreCache == false {
                        response = ZYCacheCenter.sharedInstance.fetchMemoryCache(withServiceIdentifier: child.serviceIdentifier,
                                                                                 path: child.path,
                                                                                 params: reformedParams)
                    }
                    
                    // 再检查是否有磁盘缓存
                    if cachePolicy == .disk && shouldIgnoreCache == false {
                        response = ZYCacheCenter.sharedInstance.fetchDiskCache(withServiceIdentifier: child.serviceIdentifier,
                                                                               path: child.path,
                                                                               params: reformedParams)
                    }
                    
                    if response != nil {
                        successedOnCallAPI(withResponse: response!)
                        return 0
                    }
                    
                    // 实际的网络请求
                    if isReachable {
                        isLoading = true
                        
                        let service: ZYServiceProtocol = ZYServiceFactory.sharedInstance.service(withIdentifier: child.serviceIdentifier)
        
                        if var request: URLRequest = service.requestWithParams(params: reformedParams, path: child.path, requestType: child.method) {
                            
                            request.originRequestParams = params
                            request.actualRequestParams = reformedParams
                            request.service = service
                          
                            ZYLogger.logDebugInfo(withRequest: request, apiName: child.path, service: service)
                            
                            let requestId: Int = ZYAPIProxy.sharedInstance.callAPI(withRequest: request, success: { (response) -> () in
                                
                                self.successedOnCallAPI(withResponse: response)
                                
                            }, fail: { (response: ZYURLResponse) -> Void in
                                
                                var errorType: ZYAPIManagerErrorType = .defaultStatus
                                
                                switch response.status {
                                case .errorCancel?:
                                    errorType = .canceled
                                case .errorTimeOut?:
                                    errorType = .timeOut
                                case .errorNoNetwork?:
                                    errorType = .noNetWork
                                default: break
                                }
                                
                                self.failOnCallAPI(withResponse: response, errorType: errorType)
                            })
                            
                            requestIdList.append(requestId)
                            
                            var params: Dictionary<String, Any> = reformedParams ?? [String: Any]()
                            params[kZYAPIBaseManagerRequestId] = requestId
                            afterCallAPI(withParams: params)
                            
                            return requestId
                        }
                    } else {
                        failOnCallAPI(withResponse: nil, errorType: .noNetWork)
                        return requestId
                    }
                    
                } else {
                    failOnCallAPI(withResponse: nil, errorType: errorType)
                }
            }
        }
        
        return requestId
    }
    
    class func loadData(withParams params: Dictionary<String, Any>?, success successCallBack: ((ZYBaseAPIManager) -> ())?, fail failCallBack: ((ZYBaseAPIManager) -> ())?) -> Int {
        return self.init().loadData(withParams: params, success: successCallBack, fail: failCallBack)
    }
    
    func loadData(withParams params: Dictionary<String, Any>?, success successCallBack: ((ZYBaseAPIManager) -> ())?, fail failCallBack: ((ZYBaseAPIManager) -> ())?) -> Int {
        successBlock = successCallBack
        failBlock = failCallBack
        
        return loadData(withParams: params)
    }
    
}


// MARK: - API Callbacks
extension ZYBaseAPIManager {
    
    private func successedOnCallAPI(withResponse response: ZYURLResponse) {
        
        isLoading = false
        self.response = response
        
        if let content = response.content {
            rawData = content
        } else {
            rawData = response.responseData
        }
        
        removeRequestId(withRequestId: response.requestId)
        
        let errorType: ZYAPIManagerErrorType = validator?.manager(self, isCorrectWithCallBackData: response.content as! Dictionary<String, Any>?) ?? .noError
        
        if errorType == .noError {
            
            if let child = child {
                if cachePolicy != .noCache && response.isCache == false {
                    
                    if cachePolicy == .memory {
                        ZYCacheCenter.sharedInstance.saveMemoryCache(withResponse: response,
                                                                     serviceIdentifier: child.serviceIdentifier,
                                                                     path: child.path,
                                                                     cacheTime: memoryCacheSecond)
                    }
                    
                    if cachePolicy == .disk {
                        ZYCacheCenter.sharedInstance.saveDiskCache(withResponse: response,
                                                                   serviceIdentifier: child.serviceIdentifier,
                                                                   path: child.path,
                                                                   cacheTime: diskCacheSecond)
                    }
                }
            }
            
            interceptor?.manager?(self, didReceive: response)
            
            
            if beforePerformSuccess(withResponse: response) {
                DispatchQueue.main.async {
                    self.delegate?.managerCallAPIDidSuccess(self)
                    self.successBlock?(self)
                }
            }
            afterPerformSuccess(withResponse: response)
        } else {
            failOnCallAPI(withResponse: response, errorType: errorType)
        }
    }
    
    private func failOnCallAPI(withResponse response: ZYURLResponse?, errorType: ZYAPIManagerErrorType) {
        
        isLoading = false
        
        if let response = response {
            self.response = response
            removeRequestId(withRequestId: response.requestId)
            
            if let content = response.content as? Dictionary<String, Any> {
                // user token 无效，重新登录
                let resCode: String? = content["resCode"] as? String
                if resCode == "00100009" || resCode == "05111001" || resCode == "05111002" || resCode == "1080002" {
                    NotificationCenter.default.post(name: NSNotification.Name(kZYUserTokenIllegalNotification),
                                                    object: nil,
                                                    userInfo: [
                                                        kZYUserTokenNotificationUserInfoKeyManagerToContinue: self
                        ])
                    return
                }
                
                // 可以自动处理的错误
                let errorCode: String? = content["errorCode"] as? String
                let errorMessage: String? = content["errorMsg"] as? String
                
                if errorMessage == "invalid token" || errorMessage == "access_token is required" || errorCode == "BL10015" {
                    // token 失效
                    NotificationCenter.default.post(name: NSNotification.Name(kZYUserTokenInvalidNotification),
                                                    object: nil,
                                                    userInfo: [
                                                        kZYUserTokenNotificationUserInfoKeyManagerToContinue: self
                        ])
                    return
                }
            }
        }
        
        self.errorType = errorType
        
        // user token 无效，重新登录
        if errorType == .needLogin {
            NotificationCenter.default.post(name: NSNotification.Name(kZYUserTokenIllegalNotification),
                                            object: nil,
                                            userInfo: [
                                                kZYUserTokenNotificationUserInfoKeyManagerToContinue: self
                ])
            return
        }
        
        
        // 可以自动处理的错误
        if errorType == .needAccessToken {
            NotificationCenter.default.post(name: NSNotification.Name(kZYUserTokenInvalidNotification),
                                            object: nil,
                                            userInfo: [
                                                kZYUserTokenNotificationUserInfoKeyManagerToContinue: self
                ])
            return
        }
        
        // 常规错误
        switch errorType {
        case .noNetWork:
            errorMessage = "无网络连接，请检查网络"
        case .timeOut:
            errorMessage = "请求超时"
        case .canceled:
            errorMessage = "您已取消"
        case .downGrade:
            errorMessage = "网络拥塞"
        default: break
        }
        
        // 其他错误
        DispatchQueue.main.async {
            self.interceptor?.manager?(self, didReceive: response)
            self.delegate?.managerCallAPIDidFailed(self)
            self.failBlock?(self)
            
            if let response = response {
                self.afterPerformFail(withResponse: response)
            }
        }
    }
    
}


// MARK:

/*
 拦截器的功能可以由子类通过继承实现，也可以由其它对象实现,两种做法可以共存
 当两种情况共存的时候，子类重载的方法一定要调用一下super
 然后它们的调用顺序是BaseManager会先调用子类重载的实现，再调用外部interceptor的实现
 
 notes:
 正常情况下，拦截器是通过代理的方式实现的，因此可以不需要以下这些代码
 但是为了将来拓展方便，如果在调用拦截器之前manager又希望自己能够先做一些事情，所以这些方法还是需要能够被继承重载的
 所有重载的方法，都要调用一下super,这样才能保证外部interceptor能够被调到
 这就是decorate pattern
 */
extension ZYBaseAPIManager {
    
    private func beforePerformSuccess(withResponse response: ZYURLResponse) -> Bool {
        
        var result: Bool = true
        
        errorType = .success
        
        if interceptor as? ZYBaseAPIManager != self {
            result = interceptor?.manager?(self, beforePerformSuccessWith: response) ?? true
        }
        
        return result
    }
    
    private func afterPerformSuccess(withResponse response: ZYURLResponse) {
        
        if interceptor as? ZYBaseAPIManager != self {
            interceptor?.manager?(self, afterPerformSuccessWith: response)
        }
        
    }
    
    private func beforePerformFail(withResponse response: ZYURLResponse) -> Bool {
        
        var result: Bool = true
        
        if interceptor as? ZYBaseAPIManager != self {
            result = interceptor?.manager?(self, beforePerformFailWith: response) ?? true
        }
        
        return result
    }
    
    private func afterPerformFail(withResponse response: ZYURLResponse) {
        
        if interceptor as? ZYBaseAPIManager != self {
            interceptor?.manager?(self, afterPerformFailWith: response)
        }
        
    }
    
    
    //只有返回true才会继续调用API
    func shouldCallAPI(withParams params: Dictionary<String, Any>?) -> Bool {
        
        if interceptor as? ZYBaseAPIManager? != self {
            if let result = interceptor?.manager?(self, shouldCallAPIWith: params) {
                return result
            }
        }
        
        return true
    }
    
    
    func afterCallAPI(withParams params: Dictionary<String, Any>?) {
        if interceptor as? ZYBaseAPIManager? != self {
            interceptor?.manager?(self, afterCallAPIWith: params)
        }
    }
    
}


// MARK: - Methods For Child
extension ZYBaseAPIManager {
    
    func cleanData() {
        rawData = nil
        errorType = .defaultStatus
    }
    
    //如果需要在调用API之前额外添加一些参数，比如pageNumber和pageSize之类的就在这里添加
    //子类中覆盖这个函数的时候就不需要调用[super reformParams:params]了
    @objc func reformParams(_ params: Dictionary<String, Any>?) -> Dictionary<String, Any>? {
        //let childIMP: IMP = method_getImplementation(class_getInstanceMethod((type(of: self.child) as! AnyClass), #selector(reformParams(_:)))!)
        
        if let child = child {
            let childIMP: IMP = (self.child as! ZYBaseAPIManager).method(for: #selector(reformParams(_:)))
            //let selfIMP: IMP = method_getImplementation(class_getInstanceMethod(type(of: self), #selector(reformParams(_:)))!)
            let selfIMP: IMP = self.method(for: #selector(reformParams(_:)))
            
            if childIMP == selfIMP {
                return params
            } else {
                // 如果child是继承得来的，那么这里就不会跑到，会直接跑子类中的IMP。
                // 如果child是另一个对象，就会跑到这里
                let result: Dictionary<String, Any>? = child.reformParams(params: params)
                if let result = result {
                    return result
                } else {
                    return params
                }
            }
        } else {
            return params
        }
    }
    
}


// MARK: - Private Methods
extension ZYBaseAPIManager {
    
    func removeRequestId(withRequestId requestId: Int) {
        for index in 0 ..< requestIdList.count {
            if requestIdList[index] == requestId {
                requestIdList.remove(at: index)
                break
            }
        }
    }
    
}
