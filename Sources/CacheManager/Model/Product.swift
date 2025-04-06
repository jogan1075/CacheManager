//
//  Product.swift
//  CacheManager
//
//  Created by Jonathan Muñoz on 06-04-25.
//

import Foundation

struct ProductResponse: Codable {
    let products: [Product]
    let total, skip, limit: Int
}

// MARK: - Product
struct Product: Codable, Identifiable {
    let id: Int
    let title, description: String
    let category: String
    let price: Double
}
