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
    
    public init(_ config: GithubConfig, services: inout Services, jwtSecret: String) throws {
        self.config = config
        
        Imperial.GitHubRouter.baseURL = ApiCoreBase.configuration.auth.github.host.finished(with: "/")
        Imperial.GitHubAuth.idEnvKey = "APICORE_AUTH_GITHUB_CLIENT"
        Imperial.GitHubAuth.secretEnvKey = "APICORE_AUTH_GITHUB_SECRET"
        
        services.register { _ in
            GithubJWTService(secret: jwtSecret)
        }
        
        GithubLoginController.config = config
        
        ApiCoreBase.controllers.append(GithubLoginController.self)
    }
    
}
