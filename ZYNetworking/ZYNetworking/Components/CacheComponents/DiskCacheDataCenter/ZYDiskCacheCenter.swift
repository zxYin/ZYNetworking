//
//  ZYDiskCacheCenter.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/7/27.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import UIKit

private let kZYDiskCacheCenterCachedObjectKeyPrefix: String = "kZYDiskCacheCenterCachedObjectKeyPrefix"

class ZYDiskCacheCenter: NSObject {

    public func fetchCachedRecord(withKey key: String) -> ZYURLResponse? {
        
        var response: ZYURLResponse? = nil
        let actualKey: String = kZYDiskCacheCenterCachedObjectKeyPrefix + key
        let data: Data? = UserDefaults.standard.data(forKey: actualKey)
        
        if let data = data {
            if let fetchedContent = (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Dictionary<String, Any>) {
                let lastUpdateTimeNumber: Int = fetchedContent["lastUpdateTime"] as! Int
                let lastUpdataDate: Date = Date.init(timeIntervalSince1970: TimeInterval(lastUpdateTimeNumber))
                let timeInterval: TimeInterval = Date().timeIntervalSince(lastUpdataDate)
                
                if timeInterval < (fetchedContent["cacheTime"] as! Double) {
                    response = ZYURLResponse.init(data: try? JSONSerialization.data(withJSONObject: fetchedContent["content"]!, options: .prettyPrinted))
                } else {
                    UserDefaults.standard.removeObject(forKey: actualKey)
                    UserDefaults.standard.synchronize()
                }
            }
        }
        
        return response
        
    }
    
    public func saveCache(withResponse response: ZYURLResponse, key: String, cacheTime: TimeInterval) {
        
        let data: Data? = try? JSONSerialization.data(withJSONObject: [
                                                                        "content": response.content,
                                                                        "lastUpdateTime": Date().timeIntervalSince1970,
                                                                        "cacheTime": cacheTime
                                                                      ],
                                                             options: .prettyPrinted)
        if data != nil {
            let actualKey: String = kZYDiskCacheCenterCachedObjectKeyPrefix + key
            UserDefaults.standard.set(data, forKey: actualKey)
            UserDefaults.standard.synchronize()
        }
        
    }
    
    public func cleanAll() {
        let defaultsDictionary: Dictionary<String, Any> = UserDefaults.standard.dictionaryRepresentation()
        let keys = defaultsDictionary.keys.filter( {(key: String) -> Bool in
            return key.hasPrefix(kZYDiskCacheCenterCachedObjectKeyPrefix)
            })
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
    }
    
}
