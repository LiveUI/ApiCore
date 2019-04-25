//
//  UserInfo.swift
//  GitlabLogin
//
//  Created by Ondrej Rafaj on 27/03/2019.
//

import Foundation
import JWT


public struct GitlabUserInfo: JWTPayload, UserSource {
    
    public enum Error: Swift.Error {
        case missingEmail
    }
    
    /// Expiration
    var exp: ExpirationClaim
    
    public let username: String
    public let firstname: String
    public let lastname: String
    public let email: String
    public let avatar: String?
    public let companies: [String]
    
    public var token: String?
    public let gitlabToken: String
    
    public var info: [String : String]?
    
    /// Initializer
    init(user: GitlabUser, gitlabToken: String, token: String? = nil) throws {
        username = user.username
        
        let name = user.name ?? ""
        if name.isEmpty {
            firstname = user.username
            lastname = ""
        } else {
            let parts = name.split(separator: " ")
            firstname = String(parts[0])
            if parts.count > 1 {
                lastname = String(parts.last ?? "")
            } else {
                lastname = ""
            }
        }
        
        email = user.email
        avatar = user.avatarURL
        companies = user.organization?.split(separator: ",").map({ String($0).trimmingCharacters(in: .whitespacesAndNewlines) }) ?? []
        
        exp = ExpirationClaim(value: Date().addingTimeInterval(120))
        
        self.gitlabToken = gitlabToken
        self.token = token
    }
    
    /// Verify
    public func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
    
}
