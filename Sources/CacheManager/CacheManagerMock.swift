//
//  CacheManagerMock.swift
//  CacheManager
//
//  Created by Jonathan Muñoz on 06-04-25.
//

import Foundation


class CacheManagerMock: CacheService {
    // In-memory storage for mocked cache
    private var mockStorage: [String: Any] = [:]
    private var mockExpirations: [String: Date] = [:]
    
    // MARK: - CacheService Protocol Methods
    
    func save<T: Codable>(_ object: T, forKey key: String, expiration: CacheExpiration) {
        mockStorage[key] = object
        
        // Set expiration if applicable
        if let minutes = expiration.minutes {
            mockExpirations[key] = Date().addingTimeInterval(minutes * 60)
        }
    }
    
    func get<T: Codable>(forKey key: String) -> T? {
        // Check expiration
        if let expirationDate = mockExpirations[key], Date() > expirationDate {
            removeObject(forKey: key)
            return nil
        }
        
        return mockStorage[key] as? T
    }
    
    func removeObject(forKey key: String) {
        mockStorage.removeValue(forKey: key)
        mockExpirations.removeValue(forKey: key)
    }
    
    func clearCache() {
        mockStorage.removeAll()
        mockExpirations.removeAll()
    }
    
    func clearExpiredCache() {
        let now = Date()
        let expiredKeys = mockExpirations.filter { $0.value < now }.map { $0.key }
        expiredKeys.forEach { removeObject(forKey: $0) }
    }
    
    // MARK: - Mock Specific Methods
    
    
    /// Preload mock data into the cache
    func preloadData() {
        // Example mock data
        
        let mockProducts = ProductResponse(
            products: [
                Product(
                    id: 1,
                    title: "Wireless Earbuds",
                    description: "High-quality wireless earbuds with noise cancellation.",
                    category: "Electronics",
                    price: 99.99
                ),
                Product(
                    id: 2,
                    title: "Smartphone",
                    description: "Latest model smartphone with advanced features.",
                    category: "Electronics",
                    price: 699.99
                )            ],
            total: 2,
            skip: 0,
            limit: 2
        )
        
        let mockUsers = [
            User(id: 1,
                 name: "Mock User",
                 username: "mockuser",
                 email: "mock@example.com",
                 address: Address(street: "Mock Street",
                                suite: "Suite 1",
                                city: "Mock City",
                                zipcode: "12345",
                                geo: Geo(lat: "0", lng: "0")),
                 phone: "123-456-7890",
                 website: "mock.com",
                 company: Company(name: "Mock Co",
                                catchPhrase: "Mock Phrase",
                                bs: "Mock BS"))
        ]
        
        // Save mock data with appropriate cache keys
        save(mockProducts, forKey: CacheConfig.shared.cacheKey(for: .products), expiration: .hours(1))
        save(mockUsers, forKey: CacheConfig.shared.cacheKey(for: .users), expiration: .days(1))
        
        save(0,forKey: "Int",expiration: .never)
        save("test",forKey: "String",expiration: .never)
        save(true,forKey: "Boolean",expiration: .never)
        save(0.0,forKey: "Long",expiration: .never)
       
        clearCache()
        removeObject(forKey: "Long")
    }
}
