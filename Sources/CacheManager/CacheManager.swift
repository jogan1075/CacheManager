//
//  CacheManager.swift
//  CacheManager
//
//  Created by Jonathan Muñoz on 06-04-25.
//

import Foundation

struct CachedObject<T: Codable>: Codable {
    let object: T
    let timestamp: Date
    let expirationMinutes: Double?
    
    var isExpired: Bool {
        guard let expirationMinutes = expirationMinutes else { return false }
        let expirationInterval = TimeInterval(expirationMinutes * 60)
        return Date().timeIntervalSince(timestamp) > expirationInterval
    }
}

public class CacheManager: CacheService {
    private let storage = UserDefaults.standard
    private var memoryCache = NSCache<NSString, CacheWrapper>()
    private var memoryCacheKeys = Set<String>() // Track memory cache keys
    
   public  init() {
        // Configure memory cache
        memoryCache.countLimit = 100 // Maximum number of objects
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB limit
    }
    
    // Wrapper class for NSCache (since it doesn't accept structs)
    private class CacheWrapper {
        let data: Data
        let timestamp: Date
        let expirationMinutes: Double?
        
        init(data: Data, timestamp: Date, expirationMinutes: Double?) {
            self.data = data
            self.timestamp = timestamp
            self.expirationMinutes = expirationMinutes
        }
        
        var isExpired: Bool {
            guard let expirationMinutes = expirationMinutes else { return false }
            let expirationInterval = TimeInterval(expirationMinutes * 60)
            return Date().timeIntervalSince(timestamp) > expirationInterval
        }
    }
    
public    func save<T: Codable>(_ object: T, forKey key: String, expiration: CacheExpiration = .never) {
        do {
            guard !key.isEmpty else { throw CacheError.invalidKey }
            
            let cachedObject = CachedObject(object: object,
                                          timestamp: Date(),
                                          expirationMinutes: expiration.minutes)
            let data = try JSONEncoder().encode(cachedObject)
            
            // Check if we're about to exceed capacity
            if memoryCache.totalCostLimit < data.count {
                throw CacheError.capacityExceeded
            }
            
            // Save to memory cache
            let wrapper = CacheWrapper(data: data,
                                     timestamp: Date(),
                                     expirationMinutes: expiration.minutes)
            memoryCache.setObject(wrapper, forKey: key as NSString)
            memoryCacheKeys.insert(key)
            
            // Save to persistent storage
            storage.set(data, forKey: key)
        } catch let error as CacheError {
            print("Cache error: \(error.localizedDescription)")
        } catch {
            print("Error saving to cache: \(error)")
        }
    }
    
    public  func get<T: Codable>(forKey key: String) -> T? {
        guard !key.isEmpty else {
            print("Cache error: \(CacheError.invalidKey.localizedDescription)")
            return nil
        }
        
        // First try memory cache
        if let wrapper = memoryCache.object(forKey: key as NSString) {
            if wrapper.isExpired {
                removeObject(forKey: key)
                print("Cache error: \(CacheError.expirationError.localizedDescription)")
                return nil
            }
            
            do {
                let cachedObject = try JSONDecoder().decode(CachedObject<T>.self, from: wrapper.data)
                return cachedObject.object
            } catch {
                print("Cache error: \(CacheError.serializationFailed.localizedDescription)")
                return nil
            }
        }
        
        // If not in memory, try persistent storage
        guard let data = storage.data(forKey: key) else {
            print("Cache error: \(CacheError.notFound.localizedDescription)")
            return nil
        }
        
        do {
            let cachedObject = try JSONDecoder().decode(CachedObject<T>.self, from: data)
            
            // Check if cached object is expired
            if cachedObject.isExpired {
                removeObject(forKey: key)
                print("Cache error: \(CacheError.expirationError.localizedDescription)")
                return nil
            }
            
            // Save back to memory cache for future use
            let wrapper = CacheWrapper(data: data,
                                     timestamp: cachedObject.timestamp,
                                     expirationMinutes: cachedObject.expirationMinutes)
            memoryCache.setObject(wrapper, forKey: key as NSString)
            
            return cachedObject.object
        } catch {
            print("Cache error: \(CacheError.serializationFailed.localizedDescription)")
            return nil
        }
    }
    
    public  func removeObject(forKey key: String) {
        // Remove from memory cache
        memoryCache.removeObject(forKey: key as NSString)
        memoryCacheKeys.remove(key) // Remove from tracking
        // Remove from persistent storage
        storage.removeObject(forKey: key)
    }
    
    public  func clearCache() {
        // Clear memory cache
        memoryCache.removeAllObjects()
        memoryCacheKeys.removeAll() // Clear tracking
        // Clear persistent storage
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
    
    public func clearExpiredCache() {
        // Clear expired items from memory cache
        for key in memoryCacheKeys {
            if let wrapper = memoryCache.object(forKey: key as NSString), wrapper.isExpired {
                memoryCache.removeObject(forKey: key as NSString)
                memoryCacheKeys.remove(key)
            }
        }
        
        // Clear expired items from persistent storage
        let keys = storage.dictionaryRepresentation().keys
        for key in keys {
            if let data = storage.data(forKey: key) {
                do {
                    struct CacheMetadata: Codable {
                        let timestamp: Date
                        let expirationMinutes: Double?
                    }
                    
                    if let metadata = try? JSONDecoder().decode(CacheMetadata.self, from: data) {
                        let isExpired = metadata.expirationMinutes.map { minutes in
                            let expirationInterval = TimeInterval(minutes * 60)
                            return Date().timeIntervalSince(metadata.timestamp) > expirationInterval
                        } ?? false
                        
                        if isExpired {
                            removeObject(forKey: key)
                        }
                    }
                }
            }
        }
    }
} 
