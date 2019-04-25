//
//  Authenticable.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 25/04/2019.
//

import Foundation


public enum AuthType: String, Codable {
    case basic = "BASIC"
    case ldap = "LDAP"
    case oauth = "OAUTH"
}


/// Main authentication protocol
public protocol Authenticable: Controller {
    
    /// Name of the service
    static var name: String { get }
    
    /// FontAwesone icon name (Ex. folder, github, apple)
    static var icon: String { get }
    
    /// Hex color for the service (no #, FF0000, 000000)
    static var color: String { get }
    
    /// Relative link to the service, (Ex. auth/github/login)
    static var link: String { get }
    
    /// Authentication type
    static var type: AuthType { get }
    
    /// Allow registration if user email doesn't exist
    static var allowRegistrations: Bool { get }
    
    /// Configure services
    static func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws
    
}
