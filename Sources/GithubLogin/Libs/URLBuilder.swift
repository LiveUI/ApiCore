//
//  URLBuilder.swift
//  GithubLogin
//
//  Created by Ondrej Rafaj on 05/03/2019.
//

import Foundation


class URLBuilder {
    
    static func link(config: Config) -> String {
        return "\(config.server.finished(with: "/"))login/oauth/authorize?scope=\(config.scopes.joined(separator: ","))&client_id=\(config.appId)"
    }
    
}
