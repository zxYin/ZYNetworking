//
//  MutateString+AXNetworkingMethods.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/7/20.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import Foundation

extension String {
    
    public mutating func appendNSURLRequest(request: NSURLRequest) {
        self += "\n\nHTTP URL:\n\t" + (request.url?.absoluteString ?? "\t\t\t\tN/A")
        self += "\n\nHTTP Header:\n" + (request.allHTTPHeaderFields?.zy_jsonString() ?? "\t\t\t\t\tN/A")
        self += "\n\nHTTP Origin Params:\n\t" + (request.originRequestParams?.zy_jsonString().zy_defaultValue(defaultData: "N/A") ?? "N/A")
        self += "\n\nHTTP Actual Params:\n\t" + (request.actualRequestParams?.zy_jsonString().zy_defaultValue(defaultData: "N/A") ?? "N/A")
        
        self += "\n\nHTTP Body:\n\t" + (String(data: request.httpBody ?? Data(), encoding: String.Encoding.utf8)?.zy_defaultValue(defaultData: "\t\t\t\tN/A") ?? "\t\t\t\tN/A")
        
        var headerString: String = String()
        
        if let headerFields = request.allHTTPHeaderFields {
            for (key, value) in headerFields {
                headerString += " -H \"" + key + ": " + value + "\""
            }
        }
        
        self += "\n\nCURL:\n\t curl"
        self += " -X " + request.httpMethod!
        
        if headerString.count > 0 { self += headerString }
        
        if (request.httpBody?.count ?? 0) > 0 {
            self += " -d '" + (String(data: request.httpBody ?? Data(), encoding: String.Encoding.utf8)?.zy_defaultValue(defaultData: "\t\t\t\tN/A") ?? "\t\t\t\tN/A") + "'"
        }
        
        self += " " + (request.url?.absoluteString ?? "\t\t\t\tN/A")
        
    }
    
}
