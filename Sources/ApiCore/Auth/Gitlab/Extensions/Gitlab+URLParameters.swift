//
//  URL+Parameters.swift
//  GitlabLogin
//
//  Created by Ondrej Rafaj on 27/03/2019.
//

import Foundation
import Vapor
import JWT


/// JWT service
final class GitlabJWTService: Service {
    
    /// Signer
    var signer: JWTSigner
    
    /// Initializer
    init(secret: String) {
        signer = JWTSigner.hs512(key: Data(secret.utf8))
    }
    
    /// Sign user info to token
    func signUserInfoToToken(info: GitlabUserInfo) throws -> String {
        var jwt = JWT(payload: info)
        
        jwt.header.typ = nil // set to nil to avoid dictionary re-ordering causing probs
        let data = try signer.sign(jwt)
        
        guard let jwtToken: String = String(data: data, encoding: .utf8) else {
            fatalError()
        }
        return jwtToken
    }
    
}



extension URL {
    
    @discardableResult func append(userInfo: GitlabUserInfo, on req: Request) throws -> URL? {
        guard var urlComponents = URLComponents(string:  absoluteString) else { return absoluteURL }
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        
        // Add user info as a JWT token
        let jwtService: GitlabJWTService = try req.make()
        let token = try jwtService.signUserInfoToToken(info: userInfo)
        
        let infoValue = URLQueryItem(name: "info", value: token)
        queryItems.append(infoValue)
        
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
    
}
