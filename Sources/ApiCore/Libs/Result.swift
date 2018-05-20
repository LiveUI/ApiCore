//
//  Result.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 24/01/2018.
//

import Foundation


/// Generic result object
public enum Result<T> {
    
    /// Complete
    case complete
    
    /// Success with generic result
    case success(T)
    
    /// Error
    case error(Swift.Error)
    
    /// Did result succeed?
    public var success: Bool {
        switch self {
        case .error(_):
            return false
        default:
            return true
        }
    }
    
    /// Error if available
    public var error: Swift.Error? {
        switch self {
        case .error(let error):
            return error
        default:
            return nil
        }
    }
    
    /// Generic object if successful
    public var object: T? {
        switch self {
        case .success(let object):
            return object
        default:
            return nil
        }
    }
    
}
