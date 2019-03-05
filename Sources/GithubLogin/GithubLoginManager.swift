//
//  GithubLoginManager.swift
//  GithubLogin
//
//  Created by Ondrej Rafaj on 03/03/2019.
//

import Foundation
import Vapor


/// GitHub login manager
public class GithubLoginManager: Service {
    
    public let config: Config
    
    public let router: Router
    
    public init(_ config: Config, router: Router) throws {
        self.config = config
        self.router = router
        
        try GithubLoginController.boot(router: router, config: config)
    }
    
}
