//
//  UserInfo.swift
//  GithubLogin
//
//  Created by Ondrej Rafaj on 27/03/2019.
//

import Foundation
import JWT


public struct GithubUserInfo: Codable, JWTPayload, UserSource {
    
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
    public let githubToken: String
    
    /// Initializer
    init(user: GithubUser, emails: GithubEmails, githubToken: String, token: String? = nil) throws {
        username = user.login
        
        let name = user.name ?? ""
        if name.isEmpty {
            firstname = user.login
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
        
        guard let email = emails.filter({ $0.primary ?? false }).first?.email else {
            throw Error.missingEmail
        }
        self.email = email
        avatar = user.avatarURL
        companies = user.company?.split(separator: ",").map({ String($0).trimmingCharacters(in: .whitespacesAndNewlines) }) ?? []
        
        exp = ExpirationClaim(value: Date().addingTimeInterval(120))
        
        self.githubToken = githubToken
        self.token = token
    }
    
    /// Verify
    public func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
    
}
