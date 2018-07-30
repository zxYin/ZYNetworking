//
//  ZYAPIProxy.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/7/20.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import UIKit
import Alamofire

typealias ZYCallBack = (_ response: ZYURLResponse) -> Void

private let kAXApiProxyDispatchItemKeyCallbackSuccess: String = "kAXApiProxyDispatchItemCallbackSuccess";
private let kAXApiProxyDispatchItemKeyCallbackFail: String = "kAXApiProxyDispatchItemCallbackFail";

public let kZYApiProxyValidateResultKeyResponseJSONObject: String = "kZYApiProxyValidateResultKeyResponseJSONObject";
public let kZYApiProxyValidateResultKeyResponseJSONString: String = "kZYApiProxyValidateResultKeyResponseJSONString";
public let kZYApiProxyValidateResultKeyResponseData: String = "kZYApiProxyValidateResultKeyResponseData";

class ZYAPIProxy: NSObject {

    static let sharedInstance = ZYAPIProxy()
    
    private override init() { }
    
    private var dispatchTable = [Int: URLSessionDataTask]()
    private var recordedRequestId: Int = 0
    lazy private var sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        let manager = SessionManager(configuration: configuration)
        manager.startRequestsImmediately = false
        
        return manager
    }()
    
    public func callAPI(withRequest request: URLRequest, success: ZYCallBack?, fail: ZYCallBack?) -> Int {
        
        var dataTask: URLSessionDataTask? = nil
        
        dataTask = sessionManager.session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            
            guard let dataTask = dataTask else { return }
            
            let requestId: Int = dataTask.taskIdentifier
            self.dispatchTable.removeValue(forKey: requestId);
            
            let result: Dictionary<String, Any>? = request.service?.resultWithResponseData(responsedata: data, response: response, request: request, error: error)
            
            let zyResponse:ZYURLResponse = ZYURLResponse(responseString: result?[kZYApiProxyValidateResultKeyResponseJSONString] as? String,
                                                              requestId: requestId,
                                                                request: request,
                                                        responseContent: result?[kZYApiProxyValidateResultKeyResponseJSONObject] as? Dictionary<String, Any>, error: error as NSError?)
            
            zyResponse.logString = ZYLogger.logDebugInfo(withResponse: response as? HTTPURLResponse, rawResponseData: data, responseString: result?[kZYApiProxyValidateResultKeyResponseJSONString] as? String, request: request, error: error as NSError?)
            
            if error != nil {
                fail?(zyResponse)
            } else {
                success?(zyResponse)
            }
        })
        
        let requestId: Int = dataTask?.taskIdentifier ?? 0
        dataTask?.resume()
        
        return requestId
    }
    
    public func cancelRequest(withRequestId requestId: Int) {
        if let requestOperation: URLSessionDataTask = dispatchTable[requestId] {
            requestOperation.cancel()
            dispatchTable.removeValue(forKey: requestId)
        }
    }
    
    public func cancelRequest(withRequestIdList requestIdList: Array<Int>) {
        for requestId in requestIdList {
            cancelRequest(withRequestId: requestId)
        }
    }
    
}
