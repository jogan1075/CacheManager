//
//  User.swift
//  CacheManager
//
//  Created by Jonathan Muñoz on 06-04-25.
//

import Foundation

enum TestEnum {
    case items
    case products
    case users
    case books(query: String, startIndex: Int, maxResults: Int)
}
