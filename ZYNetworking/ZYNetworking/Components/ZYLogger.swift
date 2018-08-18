//
//  ZYLogger.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/7/20.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import UIKit
import CTMediator

class ZYLogger: NSObject {

    class public func logDebugInfo(withRequest request: NSURLRequest, apiName: String, service: ZYServiceProtocol) -> String {
        
        var logString: String = ""
#if DEBUG
        if CTMediator.sharedInstance().zyNetworking_shouldPrintNetworkingLog() == false {
            return ""
        }
        
        let environment: ZYServiceAPIEnvironment? = request.service?.apiEnvironment
        var environmentString: String = ""
        
        if let environment = environment {
            if environment == .develop {
                environmentString = "Develop"
            } else {
                environmentString = "Release"
            }
        } else {
            environmentString = "N/A"
        }
        
        logString += "\n\n\n-------------------------  Request Start  -------------------------\n\n"
        
        logString += "API Name:\t\t" + apiName.zy_defaultValue(defaultData: "N/A") + "\n"
        logString += "Method:\t\t\t" + request.httpMethod! + "\n"
        logString += "Service:\t\t" + String(describing: type(of: service)) + "\n"
        logString += "Status:\t\t\t" + environmentString + "\n"
        
        logString.appendNSURLRequest(request: request)
        logString += "\n\n-------------------------   Request End   -------------------------\n\n\n"
        print(logString)
#endif
        return logString
    }
    
    class public func logDebugInfo(withResponse response: HTTPURLResponse?, rawResponseData: Data?, responseString: String?, request: NSURLRequest, error: NSError?) -> String {
        
        var logString: String = ""
#if DEBUG
        if CTMediator.sharedInstance().zyNetworking_shouldPrintNetworkingLog() == false {
            return ""
        }
        
        logString += "\n\n\n-------------------------   API Response   -------------------------\n\n"
        
        if let response = response {
            logString += "Status:\t" + String(response.statusCode) + "\t(" + HTTPURLResponse.localizedString(forStatusCode: response.statusCode) + ")\n\n"
        } else {
            logString += "Status:\n\tN/A\t\n\n"
        }
        
        logString += "Content:\n\t" + (responseString?.zy_defaultValue(defaultData: "N/A") ?? "N/A") + "\n\n"
        
        let urlString = (request.url?.absoluteString ?? "N/A")
        logString += "Request URL:\n\t" + urlString + "\n\n"
        
        logString += "Request Data:\n\t" + (request.originRequestParams?.zy_jsonString().zy_defaultValue(defaultData: "N/A") ?? "N/A") + "\n\n"
        logString += "Raw Response String:\n\t" + (String(data: rawResponseData ?? Data(), encoding: String.Encoding.utf8)?.zy_defaultValue(defaultData: "N/A") ?? "N/A") + "\n\n"
        
        
        logString += "Raw Response Header:\n\t" + (response?.allHeaderFields.zy_jsonString().zy_defaultValue(defaultData: "N/A") ?? "N/A") + "\n\n"
        
        if let error = error {
            logString += "Error Domain:\t\t\t\t\t\t\t" + error.domain + "\n"
            logString += "Error Domain Code:\t\t\t\t\t\t" + String(error.code) + "\n"
            logString += "Error Localized Description:\t\t\t" + error.localizedDescription + "\n"
            logString += "Error Localized Failure Reason:\t\t\t" + (error.localizedFailureReason ?? "N/A") + "\n"
            logString += "Error Localized Recovery Suggestion:\t" + (error.localizedRecoverySuggestion ?? "N/A") + "\n\n"
        }
        
        logString += "\n------------------------  Related Request Content  ------------------------\n"
        logString.appendNSURLRequest(request: request)
        logString += "\n\n-------------------------   Response End   -------------------------\n\n\n"
        print(logString)
#endif
        return logString
    }
    
    class public func logDebugInfo(withCachedResponse response: ZYURLResponse, path: String, service: ZYServiceProtocol, params: Dictionary<String, Any>?) -> String {
        
        var logString: String = ""
#if DEBUG
        if CTMediator.sharedInstance().zyNetworking_shouldPrintNetworkingLog() == false {
            return ""
        }
        
        logString += "\n\n\n-------------------------  Cached Response  -------------------------\n\n"
        logString += "API Name:\t\t" + path.zy_defaultValue(defaultData: "N/A") + "\n"
        logString += "Service:\t\t" + String(describing: type(of: service)) + "\n"
        logString += "Method Name:\t" + path + "\n"
        logString += "Params:\n" + (params?.zy_jsonString().zy_defaultValue(defaultData: "N/A") ?? "N/A") + "\n\n"
        logString += "Origin Params:\n" + (response.originRequestParams?.zy_jsonString().zy_defaultValue(defaultData: "N/A") ?? "N/A") + "\n\n"
        logString += "Actual Params:\n" + (response.acturlRequestParams?.zy_jsonString().zy_defaultValue(defaultData: "N/A") ?? "N/A") + "\n\n"
        logString += "Content:\n\t" + (response.contentString?.zy_defaultValue(defaultData: "N/A") ?? "N/A") + "\n\n"
        
        logString += "\n\n-------------------------   Response End   -------------------------\n\n\n"
        print(logString)
#endif
        return logString
    }
    
}
