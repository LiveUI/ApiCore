//
//  Config.swift
//  GithubLogin
//
//  Created by Ondrej Rafaj on 05/03/2019.
//

import Foundation


public struct Config {
    
    public var server: String = "https://github.com/"
    
    public let appId: String
    
    public let sharedSecret: String
    
    public var scopes: [String] = ["view_profile", "user:read"]
    
    public init(server: String = "https://github.com/", appId: String, sharedSecret: String) {
        self.server = server
        self.appId = appId
        self.sharedSecret = sharedSecret
    }
    
}
