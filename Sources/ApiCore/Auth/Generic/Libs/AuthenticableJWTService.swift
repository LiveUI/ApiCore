//
//  AuthenticableJWTService.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 25/04/2019.
//

import Foundation
import JWT


/// JWT service
final class AuthenticableJWTService: Service {
    
    /// Signer
    var signer: JWTSigner
    
    /// Initializer
    init(secret: String) {
        signer = JWTSigner.hs512(key: Data(secret.utf8))
    }
    
    /// Sign user info to token
    func signAuthenticatedUserInfoToToken(_ info: Authenticated) throws -> String {
        var jwt = JWT(payload: info)
        
        jwt.header.typ = nil // set to nil to avoid dictionary re-ordering causing probs
        let data = try signer.sign(jwt)
        
        guard let jwtToken: String = String(data: data, encoding: .utf8) else {
            fatalError()
        }
        return jwtToken
    }
    
}
