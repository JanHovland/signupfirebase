//
//  CacheManager.swift
//  signupfirebase
//
//  Created by Jan Hovland on 24/02/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import Foundation

enum CacheConfiguration {
    static let maxObjects = 100
    static let maxSixe = 1024 * 1024 * 40
}

final class CacheManager {
    
    static let shared: CacheManager = CacheManager()
    private static var cache: NSCache<NSString, AnyObject> = {
        let cache = NSCache<NSString, AnyObject>()
        cache.countLimit = CacheConfiguration.maxObjects
        cache.totalCostLimit = CacheConfiguration.maxSixe
        
        return cache
    }()
    
    private init() { }
    
    func cache(object: AnyObject, key: String) {
        CacheManager.cache.setObject(object, forKey: key as NSString)
    }
    
    func getFromCache(key: String) -> AnyObject? {
        return CacheManager.cache.object(forKey: key as NSString)
    }
    
}
