//
//  GitlabEmail.swift
//  GithubLogin
//
//  Created by Ondrej Rafaj on 27/03/2019.
//

import Foundation

public typealias GithubEmails = [GithubEmail]

public struct GithubEmail: Codable {
    
    public let email: String
    public let primary: Bool?
    public let verified: Bool?
    public let visibility: String?
    
}
