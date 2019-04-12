//
//  GitlabLoginManager.swift
//  GitlabLogin
//
//  Created by Ondrej Rafaj on 03/03/2019.
//

import Foundation
import Vapor
import Imperial


/// Gitlab login manager
public class GitlabLoginManager: Service {
    
    public let config: GitlabConfig
    
    public init(_ config: GitlabConfig, services: inout Services, jwtSecret: String) throws {
        self.config = config
        
        Imperial.GitlabRouter.baseURL = ApiCoreBase.configuration.auth.gitlab.host.finished(with: "/")
        Imperial.GitlabAuth.idEnvKey = "APICORE_AUTH_GITLAB_APPLICATION"
        Imperial.GitlabAuth.secretEnvKey = "APICORE_AUTH_GITLAB_SECRET"
        Imperial.GitlabRouter.callbackURL = "\(Me.serverURL().absoluteString.finished(with: "/"))auth/gitlab/callback"
        
        services.register { _ in
            GitlabJWTService(secret: jwtSecret)
        }
        
        GitlabLoginController.config = config
        
        ApiCoreBase.controllers.append(GitlabLoginController.self)
    }
    
}
