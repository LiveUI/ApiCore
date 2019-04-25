//
//  UserSource.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 29/03/2019.
//

import Foundation
import Vapor


/// Common interface for third-party authentication
public protocol UserSource: Codable {
    
    // Username / nickname
    var username: String { get }
    
    /// First name
    var firstname: String { get }
    
    /// Last name
    var lastname: String { get }
    
    /// Email
    var email: String { get }
    
    /// ApiCore permanent login token
    var token: String? { get set }
    
    /// Additional info
    var info: [String: String]? { get set }
    
}


extension UserSource {
    
    public func asUser(on req: Request) throws -> User {
        let user = User(
            username: username,
            firstname: firstname,
            lastname: lastname,
            email: email,
            password: nil,
            token: nil,
            disabled: false,
            su: false
        )
        return user
    }
    
}
