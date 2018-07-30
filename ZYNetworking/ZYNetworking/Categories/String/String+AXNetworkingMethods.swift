//
//  String+AXNetworkingMethods.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/7/29.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import Foundation

public extension String {
    
    
    public func ZY_MD5() -> String {
        
        let inputData = self.cString(using: String.Encoding.utf8);
        let outputData = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(inputData!,(CC_LONG)(strlen(inputData!)), outputData)
        
        let md5String = NSMutableString();
        
        for i in 0 ..< 16 {
            md5String.appendFormat("%02x", outputData[i])
        }
        
        free(outputData)
        
        return md5String as String
    }
    
    public func ZY_SHA1() -> String {
        
        let data: Data = self.data(using: .utf8)!
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        let newData = NSData.init(data: data)
        
        CC_SHA1(newData.bytes, CC_LONG(data.count), &digest)
        let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        
        for byte in digest {
            output.appendFormat("%02x", byte)
        }
        
        return output as String
    }
    
    public func ZY_Base64Encode() -> String {
        
        let data: Data = self.data(using: .utf8)!
        let base64String: String = data.base64EncodedString(options: .init(rawValue: 0))
        
        return base64String
    }
    
}
