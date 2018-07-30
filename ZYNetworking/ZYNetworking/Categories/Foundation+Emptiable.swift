//
//  Foundation+Emptiable.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/7/18.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import Foundation

public protocol EmptiableProtocol {
    
    func zy_isEmptyObject() -> Bool
    
    func zy_defaultValue<T>(defaultData: Any) -> T
    
}

extension String: EmptiableProtocol {
    
    public func zy_isEmptyObject() -> Bool {
        if count == 0 {
            return true
        }
        return false
    }
    
    public func zy_defaultValue<String>(defaultData: Any) -> String {
        
        guard let defaultString = defaultData as? String else { return self as! String }
        
        if zy_isEmptyObject() { return defaultString }
        
        return self as! String
    }
    
}

extension Array: EmptiableProtocol {
    
    public func zy_defaultValue<Array>(defaultData: Any) -> Array {
        
        guard let defaultArray = defaultData as? Array else { return self as! Array }
        
        if zy_isEmptyObject() { return defaultArray }
        
        return self as! Array
    }
    
    
    public func zy_isEmptyObject() -> Bool {
        if count == 0 {
            return true
        }
        return false
    }
    
}

extension Dictionary: EmptiableProtocol {
    public func zy_defaultValue<Dictionary>(defaultData: Any) -> Dictionary {
        
        guard let defaultDictionary = defaultData as? Dictionary else { return self as! Dictionary }
        
        if zy_isEmptyObject() { return defaultDictionary }
        
        return self as! Dictionary
    }
    
    
    public func zy_isEmptyObject() -> Bool {
        if count == 0 {
            return true
        }
        return false
    }
    
}

