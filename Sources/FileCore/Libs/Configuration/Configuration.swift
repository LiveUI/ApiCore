//
//  Configuration.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation
import S3


extension FileCoreManager.Configuration {
    
    /// Get local filesystem configuration if available
    public func localConfig() -> LocalConfig? {
        switch self {
        case .local(let config):
            return config
        default:
            return nil
        }
    }
    
    /// Get S3 configuration and bucket if available
    public func s3Config() -> (config: S3Signer.Config, bucket: String)? {
        switch self {
        case .s3(let config, let bucket):
            return (config: config, bucket: bucket)
        default:
            return nil
        }
    }
    
}
