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
    
    /// Server subtitle
    public let subtitle: String?
    
    /// Server URL
    public let url: String
    
    /// Server icons
    public let icons: [Icon]
    
    
    /// Initializer
    ///
    /// - Parameter req: Request
    /// - Throws: yes
    public init(_ req: Request) throws {
        let fm = try req.makeFileCore()
        name = ApiCoreBase.configuration.server.name
        subtitle = ApiCoreBase.configuration.server.subtitle
        url = req.serverURL().absoluteString
        icons = try IconSize.all.sorted(by: { $0.rawValue < $1.rawValue }).map({
            let url = try fm.url(for: "server/image/\($0.rawValue)", on: req)
            return Info.Icon(size: $0, url: url)
        })
    }
    
}
