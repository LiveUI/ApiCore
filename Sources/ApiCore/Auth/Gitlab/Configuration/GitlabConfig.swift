//
//  GitlabConfig.swift
//  GitlabLogin
//
//  Created by Ondrej Rafaj on 05/03/2019.
//

import Foundation
import Vapor


public struct GitlabConfig {
    
    public let server: String
    
    public let api: String
    
    public var scopes: [String] = ["read_user", "email"]
    
    public init(server: String = "https://gitlab.com/", api: String = "https://gitlab.com/api/v4/") {
        self.server = server
        self.api = api
    }
    
}
