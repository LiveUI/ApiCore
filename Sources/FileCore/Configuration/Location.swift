//
//  Location.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation


/// Filesystem configurations
public enum Configuration {
    
    /// Local filesystem
    case local(LocalConfig)
    
    /// S3
    case s3(S3Config)
    
}


extension Configuration {
    
    /// Get local filesystem configuration if available
    public func localConfig() -> LocalConfig? {
        switch self {
        case .local(let config):
            return config
        default:
            return nil
        }
    }
    
    /// Get S3 configuration if available
    public func s3Config() -> S3Config? {
        switch self {
        case .s3(let config):
            return config
        default:
            return nil
        }
    }
    
}
