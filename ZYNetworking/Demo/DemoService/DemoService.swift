//
//  DemoService.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/7/29.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import Foundation
import Alamofire

@objc class DemoService: NSObject {
    
    private let headers: Dictionary<String, String> = {
        var tempHeaders = SessionManager.defaultHTTPHeaders
        tempHeaders[ "Content-Type"] = "application/json"
        return tempHeaders
    }()
    private let publicKey: String = "d97bab99fa506c7cdf209261ffd06652"
    private let privateKey: String = "31bb736a11cbc10271517816540e626c4ff2279a"
    private var baseURL: String {
        get {
            switch apiEnvironment {
            case .release:
                return "https://gateway.marvel.com:443/v1"
            case .develop:
                return "https://gateway.marvel.com:443/v1"
            }
        }
    }
    
}


extension DemoService: ZYServiceProtocol {
    var apiEnvironment: ZYServiceAPIEnvironment {
        get {
            return .release
        }
    }
    
    func requestWithParams(params: Dictionary<String, Any>?, path: String, requestType: ZYAPIManagerRequestType) -> NSURLRequest? {
        if requestType == .get {
            
            let tsString: String = UUID.init().uuidString
            let md5Hash: String = (tsString + privateKey + publicKey).ZY_MD5()
            let urlString: String = baseURL + "/" + path + [
                "apikey": publicKey,
                "ts": tsString,
                "hash": md5Hash,
            ].zy_transformToUrlParamString()

        
            let request: NSURLRequest? = Alamofire.request(urlString, method: .get,
                                                                parameters: nil,
                                                                  encoding: JSONEncoding.default,
                                                                   headers: headers).request as NSURLRequest?

            return request
        }
        return nil
    }
    
    func resultWithResponseData(responsedata data: Data?, response: URLResponse?, request: NSURLRequest?, error: Error?) -> Dictionary<String, Any>? {
        
        var result: Dictionary<String, Any> = [String: Any]()

        if let data = data {
            result[kZYApiProxyValidateResultKeyResponseJSONObject] = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            result[kZYApiProxyValidateResultKeyResponseJSONString] = String(data: data, encoding: .utf8)
        }
        result[kZYApiProxyValidateResultKeyResponseData] = data
        
        return result
    }
    
}
