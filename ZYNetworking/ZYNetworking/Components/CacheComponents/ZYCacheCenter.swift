//
//  ZYCacheCenter.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/7/27.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import UIKit

class ZYCacheCenter: NSObject {
    
    static let sharedInstance = ZYCacheCenter()
    
    private let memoryCacheCenter = ZYMemoryCacheDataCenter()
    private let diskCacheCenter = ZYDiskCacheCenter()
    
    private override init() { }
    
    public func fetchDiskCache(withServiceIdentifier serviceIdentifier: String, path: String, params: Dictionary<String, Any>?) -> ZYURLResponse? {

        if let response: ZYURLResponse = diskCacheCenter.fetchCachedRecord(withKey: key(withServiceIdentifier: serviceIdentifier,
                                                                                                         path: path,
                                                                                                       params: params)) {
            response.logString = ZYLogger.logDebugInfo(withCachedResponse: response,
                                                                     path: path,
                                                                  service: ZYServiceFactory.sharedInstance.service(withIdentifier: serviceIdentifier),
                                                                   params: params)
            return response
        }
        
        return nil
    }
    
    public func fetchMemoryCache(withServiceIdentifier serviceIdentifier: String, path: String, params: Dictionary<String, Any>?) -> ZYURLResponse? {
        
        if let response: ZYURLResponse = memoryCacheCenter.fetchCachedRecord(withKey: key(withServiceIdentifier: serviceIdentifier,
                                                                                                           path: path,
                                                                                                         params: params)) {
            response.logString = ZYLogger.logDebugInfo(withCachedResponse: response,
                                                                     path: path,
                                                                  service: ZYServiceFactory.sharedInstance.service(withIdentifier: serviceIdentifier),
                                                                   params: params)
            return response
        }
        
        return nil
    }
    
    public func saveDiskCache(withResponse response: ZYURLResponse, serviceIdentifier: String, path: String, cacheTime: TimeInterval) {
        
        if response.originRequestParams != nil && response.content != nil {
            diskCacheCenter.saveCache(withResponse: response, key: key(withServiceIdentifier: serviceIdentifier,
                                                                                        path: path,
                                                                                      params: response.originRequestParams),
                                                                                   cacheTime: cacheTime)
        }
        
    }
    
    public func saveMemoryCache(withResponse response: ZYURLResponse, serviceIdentifier: String, path: String, cacheTime: TimeInterval) {
        
        if response.originRequestParams != nil && response.content != nil {
            memoryCacheCenter.saveCache(withResponse: response, key: key(withServiceIdentifier: serviceIdentifier,
                                                                                          path: path,
                                                                                        params: response.originRequestParams),
                                                                                     cacheTime: cacheTime)
        }
        
    }
    
    public func cleanAllMemoryCache() {
        memoryCacheCenter.cleanAll()
    }
    
    public func cleanAllDiskCache() {
        diskCacheCenter.cleanAll()
    }
    
    // MARK: - Private Methods
    private func key(withServiceIdentifier serviceIdentifier: String, path: String, params: Dictionary<String, Any>?) -> String {
        let key: String = serviceIdentifier + path + (params?.zy_transformToUrlParamString() ?? "")
        return key
    }
}
