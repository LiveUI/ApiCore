//
//  GithubLoginManager.swift
//  GithubLogin
//
//  Created by Ondrej Rafaj on 03/03/2019.
//

import Foundation
import Vapor
import Imperial


/// GitHub login manager
public class GithubLoginManager: Service {
    
    public let config: GithubConfig
    
    public let router: Router
    
    public init(_ config: GithubConfig, router: Router, services: inout Services, jwtSecret: String) throws {
        self.config = config
        self.router = router
        
        Imperial.GitHubRouter.baseURL = ApiCoreBase.configuration.auth.github.host.finished(with: "/")
        Imperial.GitHubAuth.idEnvKey = "APICORE_AUTH_GITHUB_CLIENT"
        Imperial.GitHubAuth.secretEnvKey = "APICORE_AUTH_GITHUB_SECRET"
        
        services.register { _ in
            GithubJWTService(secret: jwtSecret)
        }
        
        try GithubLoginController.boot(router: router, config: config)
    }
    
}
