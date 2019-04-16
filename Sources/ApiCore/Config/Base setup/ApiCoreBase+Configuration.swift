
//
//  ApiCoreBase+Configuration.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 17/04/2019.
//

import Foundation


extension ApiCoreBase {
    
    /// Main system configuration
    public static var configuration: Configuration {
        get {
            if _configuration == nil {
                // Create default configuration
                _configuration = Configuration.default
                
                // Override any properties with ENV
                _configuration?.loadEnv()
            }
            guard let configuration = _configuration else {
                fatalError("Configuration couldn't be loaded!")
            }
            return configuration
        }
    }
    
}
