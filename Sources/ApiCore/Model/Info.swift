//
//  Info.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 25/05/2018.
//

import Foundation
import Vapor


/// Server info object
public struct Info: Content {
    
    /// Icons
    public struct Icon: Codable {
        
        /// Size
        public let size: IconSize
        
        /// URL
        public let url: String
        
    }
    
    /// Server name
    public let name: String
    
    /// Server URL
    public let url: String
    
    /// Server icons
    public let icons: [Icon]
    
}
