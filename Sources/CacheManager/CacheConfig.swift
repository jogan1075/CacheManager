//
//  CacheConfig.swift
//  CacheManager
//
//  Created by Jonathan Muñoz on 06-04-25.
//

import Foundation

final class CacheConfig : @unchecked Sendable{
    static let shared = CacheConfig()
    
    private init() {}
    
    func cacheKey(for enums: TestEnum) -> String {
        switch enums {
        case .items:
            return "cached_items"
        case .products:
            return "cached_products"
        case .users:
            return "cached_users"
        case .books(let query, let startIndex, _):
            return "cached_books_\(query)_\(startIndex)"
        }
    }
    
    func cacheExpiration(for enums: TestEnum) -> CacheExpiration {
        switch enums {
        case .items:
            return .minutes(30)
        case .products:
            return .hours(1)
        case .users:
            return .days(1)
        case .books:
            return .minutes(30)
        }
    }
} 
