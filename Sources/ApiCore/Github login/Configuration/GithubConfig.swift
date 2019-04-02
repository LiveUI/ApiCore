//
//  GithubConfig.swift
//  GithubLogin
//
//  Created by Ondrej Rafaj on 05/03/2019.
//

import Foundation
import Vapor


public struct GithubConfig {
    
    public let server: String
    
    public let api: String
    
    public var scopes: [String] = ["read:user", "user:email"]
    
    public init(server: String = "https://github.com/", api: String = "https://api.github.com/") {
        self.server = server
        self.api = api
    }
    
}
