//
//  CacheManager.swift
//  AsyncDataLoader
//
//  Created by NoboPay on 18/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

fileprivate class CacheData {
    let data:Data
    var creationTime:Double
    let dataType:DataType
    let URL_KEY:NSString
    init(Data _data:Data, key:NSString, type:DataType) {
        self.creationTime = Date().timeIntervalSince1970
        self.data = _data
        self.dataType = type
        self.URL_KEY = key
    }
}

class CacheManager: NSObject {
    var EXPIRE_SEC:Double = 120
    var MAX_OBJECT:Int = 10
    var MAX_MEM_SIZE:Int = 600000
    var fillCount:Int64 = -1
    static let shared = CacheManager()
    var cacheKeys:[NSString] = []
    let memoryCache =  NSCache<NSString, AnyObject>()
    var cacheTimer:Timer?
    override init() {
        super.init()
        self.memoryCache.evictsObjectsWithDiscardedContent = true
        self.cacheTimer?.tolerance = 0.2
    }

    func add(Data data:Data, forKey key:NSString, type:DataType){
        let len = Int64(data.count)
        self.fillCount += len
        if self.fillCount > self.MAX_MEM_SIZE {
            self.removeCache()
        }
        self.cacheKeys.append(key)
        let cachedObject = CacheData(Data: data, key:key, type: type)
        self.memoryCache.setObject(cachedObject as AnyObject, forKey: key)
        if self.cacheTimer == nil {
            self.startTimer()
        }
        
    }
    
    fileprivate func removeCache(){
        var minData = self.memoryCache.object(forKey: self.cacheKeys[0]) as! CacheData
        for key in self.cacheKeys {
            if let data = self.memoryCache.object(forKey: key) as? CacheData{
                if minData.creationTime > data.creationTime {
                    minData = data
                }
            }
        }
        self.memoryCache.removeObject(forKey: minData.URL_KEY)
        self.fillCount -= Int64(minData.data.count)
    }
    
    func removeCache(ForKey key:NSString)->Bool{
        if self.cacheKeys.contains(key){
            
            self.cacheKeys = self.cacheKeys.filter({ (_key) -> Bool in
                return !_key.isEqual(to: key as String)
            })
            let data = self.memoryCache.object(forKey: key) as! CacheData
            self.fillCount -= Int64(data.data.count)
            self.memoryCache.removeObject(forKey: key)
            if self.cacheKeys.isEmpty {
                self.cacheTimer?.invalidate()
                self.cacheTimer = nil
            }
            return true
        }
        return false
    }
    
    func getObject(ForKey key:NSString)->(Data,DataType){
        let obj = self.memoryCache.object(forKey: key) as! CacheData
        obj.creationTime = Date().timeIntervalSince1970
        self.memoryCache.setObject(obj, forKey: key)
        return (obj.data, obj.dataType)
    }
    
    
    fileprivate func startTimer(){
        self.cacheTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self,
                                               selector: #selector(fireTimer),
                                               userInfo: nil, repeats: true)
        
    }
    
    @objc func fireTimer() {
//        var remove_keys = [NSString]()
//        var indices = [Int]()
        let _time =  Date().timeIntervalSince1970
        for key in self.cacheKeys {
            if let data = self.memoryCache.object(forKey: key) as? CacheData{
                if self.EXPIRE_SEC + data.creationTime < _time {
                    _ = self.removeCache(ForKey: key)
                }
            }
        }
//        var index = 0
//        for key in remove_keys {
//            self.cacheKeys.remove(at: indices[index])
//            self.memoryCache.removeObject(forKey: key)
//            index += 1
//        }
    }
}
