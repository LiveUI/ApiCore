//
//  Authenticated.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 25/04/2019.
//

import Foundation
import JWT


/// When user is authenticated through the service (usually through a callback) they should return an Authenticated object back to Auth for finish the process
public struct Authenticated: JWTPayload, UserSource {
    
    public let username: String
    
    public let firstname: String
    
    public let lastname: String
    
    public let email: String
    
    public var info: [String : String]?
    
    public var token: String?
    
    
    /// Expiration claim (for signing JWT)
    let expires: ExpirationClaim
    
    /// Initializer
    init(username: String, firstname: String, lastname: String, email: String, info: [String : String]? = nil, token: String? = nil) {
        self.username = username
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.info = info
        self.token = token
        expires = ExpirationClaim(value: Date().addingTimeInterval(120))
    }
    
}


extension Authenticated {
    
    public func verify(using signer: JWTSigner) throws {
        try expires.verifyNotExpired()
    }
    
}
