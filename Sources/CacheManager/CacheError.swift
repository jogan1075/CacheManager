// The Swift Programming Language
// https://docs.swift.org/swift-book

enum CacheError: Error {
    case notFound
    case invalidData
    case serializationFailed
    case expirationError
    case storageError
    case capacityExceeded
    case invalidKey
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Data not found in cache"
        case .invalidData:
            return "Invalid data format in cache"
        case .serializationFailed:
            return "Failed to serialize/deserialize cached data"
        case .expirationError:
            return "Cache entry has expired"
        case .storageError:
            return "Failed to access cache storage"
        case .capacityExceeded:
            return "Cache capacity limit exceeded"
        case .invalidKey:
            return "Invalid cache key provided"
        case .unknown:
            return "An unknown cache error occurred"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .notFound:
            return "Try refreshing the data from the network"
        case .invalidData:
            return "Clear the cache and fetch fresh data"
        case .serializationFailed:
            return "Clear the cache and try again"
        case .expirationError:
            return "Fetch fresh data from the network"
        case .storageError:
            return "Check storage permissions and try again"
        case .capacityExceeded:
            return "Clear some cached data to free up space"
        case .invalidKey:
            return "Verify the cache key being used"
        case .unknown:
            return "Try clearing the cache and restarting the app"
        }
    }
} 
