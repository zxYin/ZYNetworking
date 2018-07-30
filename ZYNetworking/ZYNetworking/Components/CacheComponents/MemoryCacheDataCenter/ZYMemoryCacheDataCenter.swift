//
//  ZYMemoryCacheDataCenter.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/7/27.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import UIKit
import CTMediator

class ZYMemoryCacheDataCenter: NSObject {
    
    lazy private var cache: NSCache<AnyObject, AnyObject> = {
        let tempCache = NSCache<AnyObject, AnyObject>()
        tempCache.countLimit = CTMediator.sharedInstance().zyNetworking_cacheResponseCountLimit()
        return tempCache
    }()
    
    public func fetchCachedRecord(withKey key: String) -> ZYURLResponse? {
        var result: ZYURLResponse? = nil
        if let cacheRecord = cache.object(forKey: key as AnyObject) as? ZYMemoryCachedRecord {
            if cacheRecord.isOutdated || cacheRecord.isEmpty {
                cache.removeObject(forKey: key as AnyObject)
            } else {
                result = ZYURLResponse.init(data: cacheRecord.content!)
            }
        }
        return result
    }
    
    public func saveCache(withResponse response: ZYURLResponse, key: String, cacheTime: TimeInterval) {
        let cacheRecord: ZYMemoryCachedRecord = cache.object(forKey: key as AnyObject) as? ZYMemoryCachedRecord ?? ZYMemoryCachedRecord()
        cacheRecord.cacheTime = cacheTime
        cacheRecord.updateContent(try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted))
        cache.setObject(cacheRecord, forKey: key as AnyObject)
    }
    
    public func cleanAll() {
        cache.removeAllObjects()
    }
    
}
