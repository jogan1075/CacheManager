//
//  CacheService.swift
//  CacheManager
//
//  Created by Jonathan Muñoz on 06-04-25.
//

import Foundation

public protocol CacheService {
  func save<T: Codable>(_ object: T, forKey key: String, expiration: CacheExpiration)
  func get<T: Codable>(forKey key: String) -> T?
  func removeObject(forKey key: String)
  func clearCache()
  func clearExpiredCache()
}
