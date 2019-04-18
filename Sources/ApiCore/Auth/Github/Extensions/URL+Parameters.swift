//
//  URL+Parameters.swift
//  GithubLogin
//
//  Created by Ondrej Rafaj on 27/03/2019.
//

import Foundation
import Vapor
import JWT


/// JWT service
final class GithubJWTService: Service {
    
    /// Signer
    var signer: JWTSigner
    
    /// Initializer
    init(secret: String) {
        signer = JWTSigner.hs512(key: Data(secret.utf8))
    }
    
    /// Sign user info to token
    func signUserInfoToToken(info: GithubUserInfo) throws -> String {
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
    
    @discardableResult func append(userInfo: GithubUserInfo, on req: Request) throws -> URL? {
        guard var urlComponents = URLComponents(string:  absoluteString) else { return absoluteURL }
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        
        // Add user info as a JWT token
        let jwtService: GithubJWTService = try req.make()
        let token = try jwtService.signUserInfoToToken(info: userInfo)
        
        let infoValue = URLQueryItem(name: "info", value: token)
        queryItems.append(infoValue)
        
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
    
}
