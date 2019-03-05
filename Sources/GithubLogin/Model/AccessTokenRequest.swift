//
//  AccessTokenRequest.swift
//  GithubLogin
//
//  Created by Ondrej Rafaj on 05/03/2019.
//

import Foundation
import Vapor


struct AccessTokenRequest: Content {
    
    let clientId: String
    let clientSecret: String
    let code: String
    
    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case code
    }
    
    init(_ config: Config, code: String) {
        clientId = config.appId
        clientSecret = config.sharedSecret
        self.code = code
    }
    
}
