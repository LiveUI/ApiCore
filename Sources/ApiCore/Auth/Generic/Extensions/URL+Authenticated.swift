//
//  URL+Authenticated.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 25/04/2019.
//

import Foundation
import JWT

extension URL {
    
    @discardableResult func append(userInfo: Authenticated, on req: Request) throws -> URL? {
        guard var urlComponents = URLComponents(string:  absoluteString) else { return absoluteURL }
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        
        // Add user info as a JWT token
        let jwtService: AuthenticableJWTService = try req.make()
        let token = try jwtService.signAuthenticatedUserInfoToToken(userInfo)
        
        let infoValue = URLQueryItem(name: "info", value: token)
        queryItems.append(infoValue)
        
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
    
}
