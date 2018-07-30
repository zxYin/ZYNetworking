//
//  Dictionary+AXNetworkingMethods.swift
//  ZYNetworkinge
//
//  Created by 殷子欣 on 2018/7/20.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import Foundation

extension Dictionary {
    
    public func zy_jsonString() -> String {
        let jsonData: Data = try! JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8)!
    }
    
    public func zy_transformToUrlParamString() -> String {
        var paramString: String = String()
        for (key, value) in self {
            let string: String = (key == keys.first ? "?" : "&") + String(describing: key) + "=" + String(describing: value)
            paramString += string
        }
        return paramString
    }
    
}
