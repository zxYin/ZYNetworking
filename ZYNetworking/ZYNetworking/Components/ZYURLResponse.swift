//
//  ZYURLResponse.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/5/16.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import Foundation

public enum ZYURLResponseStatus {
    case success //作为底层，请求是否成功只考虑是否成功收到服务器反馈。至于签名是否正确，返回的数据是否完整，由上层的CTAPIBaseManager来决定。
    case errorTimeOut
    case errorCancel
    case errorNoNetwork // 默认除了超时以外的错误都是无网络错误。
}

public class ZYURLResponse: NSObject {
    
    private(set) var status: ZYURLResponseStatus!
    private(set) var contentString: String?
    private(set) var content: Any?
    private(set) var requestId: Int
    private(set) var request: NSURLRequest?
    private(set) var responseData: Data?
    
    private(set) var errorMessage: String?
    
    public var acturlRequestParams: Dictionary<String, Any>?
    public var originRequestParams: Dictionary<String, Any>?
    public var logString: String?
    
    private(set) var isCache: Bool
    
    init(responseString: String?, requestId: Int, request: NSURLRequest?, responseContent: Dictionary<String, Any>?, error: NSError?) {
        
        self.requestId = requestId
        self.request = request
        acturlRequestParams = request?.actualRequestParams
        originRequestParams = request?.originRequestParams
        
        isCache = false

        contentString = responseString
        content = responseContent
        responseData = (content != nil ? try? JSONSerialization.data(withJSONObject: content!, options: .prettyPrinted) : nil)
        errorMessage = error?.localizedDescription
        
        super.init()
        
        status = responseStatus(withError: error)
        
    }
    
    init(data: Data?) {

        requestId = 0
        
        isCache = true
        
        contentString = String(data: data ?? Data(), encoding: .utf8)?.zy_defaultValue(defaultData: "")
        if let data = data {
            content = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
        }
        
        responseData = data;
        
        super.init()
        
        status = responseStatus(withError: nil)
        
    }

    private func responseStatus(withError error: NSError?) -> ZYURLResponseStatus {
        
        if let error = error {
            var result: ZYURLResponseStatus = .errorNoNetwork // 除了超时默认没有网络
            
            if error.code == NSURLErrorTimedOut {
                result = .errorTimeOut
            }
            if error.code == NSURLErrorCancelled {
                result = .errorCancel
            }
            if error.code == NSURLErrorNotConnectedToInternet {
                result = .errorNoNetwork
            }
            
            return result
        } else {
            return .success
        }
        
    }
}
