//
//  ZYMemoryCachedRecord.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/7/27.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import UIKit

class ZYMemoryCachedRecord: NSObject {

    private var _content: Data?
    private(set) var content: Data? {
        set {
            _content = newValue
            lastUpdateTime = Date.init(timeIntervalSinceNow: 0)
        }
        get {
            return _content
        }
    }
    
    private(set) var lastUpdateTime: Date
    public var cacheTime: TimeInterval
    
    var isOutdated: Bool {
        get {
            let timeIntervel: TimeInterval = Date().timeIntervalSince(lastUpdateTime)
            return timeIntervel > cacheTime
        }
    }
    
    var isEmpty: Bool {
        get {
            return content == nil
        }
    }
    
    override init() {
        lastUpdateTime = Date.init(timeIntervalSinceNow: 0)
        cacheTime = Date().timeIntervalSince(lastUpdateTime)
        super.init()
    }
    
    init(content: Data?) {
        lastUpdateTime = Date.init(timeIntervalSinceNow: 0)
        cacheTime = Date().timeIntervalSince(lastUpdateTime)
        super.init()
        self.content = content
    }
    
    func updateContent(_ content: Data?) {
        self.content = content
    }
    
}
