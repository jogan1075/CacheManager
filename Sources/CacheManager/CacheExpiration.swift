//
//  CacheExpiration.swift
//  CacheManager
//
//  Created by Jonathan Muñoz on 06-04-25.
//

import Foundation

public enum CacheExpiration {
    case never
    case minutes(Double)
    case hours(Double)
    case days(Double)
    case custom(TimeInterval)
    
    var timeInterval: TimeInterval? {
        switch self {
        case .never:
            return nil
        case .minutes(let minutes):
            return TimeInterval(minutes * 60)
        case .hours(let hours):
            return TimeInterval(hours * 3600)
        case .days(let days):
            return TimeInterval(days * 86400)
        case .custom(let interval):
            return interval
        }
    }
    
    var minutes: Double? {
        guard let interval = timeInterval else { return nil }
        return interval / 60
    }
} 
