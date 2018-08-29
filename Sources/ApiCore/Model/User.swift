//
//  User.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 11/12/2017.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
import DbCore


/// Users array type typealias
public typealias Users = [User]


/// User object
public final class User: DbCoreModel {
    
    /// Registration object
    public struct Registration: Content {
        
        /// Template object
        public struct Template: Content {
            
            /// Verification
            public var verification: String
            
            /// Server link
            public var serverLink: String
            
            /// User registration
            public var user: Registration
        }
        
        /// Username
        public var username: String
        
        /// First name
        public var firstname: String
        
        /// Last name
        public var lastname: String
        
        /// Email
        public var email: String
        
        /// Password
        public var password: String
        
        /// Convert to user
        public func newUser(on req: Request) throws -> User {
            let user = try User(username: username, firstname: firstname, lastname: lastname, email: email, verification: UUID().uuidString, password: password.passwordHash(req), disabled: false, su: false)
            return user
        }
        
    }
    
    /// Auth
    public struct Auth {
        
        /// Login object
        public struct Login: Content {
            
            /// Email
            public let email: String
            
            /// Password
            public let password: String
            
            /// Initializer (optional)
            public init?(email: String, password: String) {
                guard email.count > 0, password.count > 0 else {
                    return nil
                }
                self.email = email
                self.password = password
            }
            
        }
        
        /// Token object
        public struct Token: Content {
            
            /// Token
            public let token: String
            
        }
        
        public struct StartRecovery: Content {
            public let email: String
            public let targetUri: String
        }
        
        public struct RecoveryTemplate: Content {
            public let recoveryJwt: String
            public var user: User
        }
        
    }
    
    /// User displayable object
    public final class Display: DbCoreModel {
        
        /// Object Id
        public var id: DbCoreIdentifier?
        
        // Username / nickname
        public var username: String
        
        /// First name
        public var firstname: String
        
        /// Last name
        public var lastname: String
        
        /// Email
        public var email: String
        
        /// Date registered
        public var registered: Date
        
        /// User disabled
        public var disabled: Bool
        
        /// Super user
        public var su: Bool
        
        /// Initializer
        public init(username: String, firstname: String, lastname: String, email: String, disabled: Bool = true, su: Bool = false) {
            self.username = username
            self.firstname = firstname
            self.lastname = lastname
            self.email = email
            self.registered = Date()
            self.disabled = disabled
            self.su = su
        }
        
        /// Initializer
        public init(_ user: User) {
            self.id = user.id
            self.username = user.username
            self.firstname = user.firstname
            self.lastname = user.lastname
            self.email = user.email
            self.registered = user.registered
            self.disabled = user.disabled
            self.su = user.su
        }
        
    }
    
    /// Public displayable object
    /// Should be displayed when accessing users you shouldn't see otherwise (so keep it private!)
    public final class AllSearch: Content {
        
        /// Object Id
        public var id: DbCoreIdentifier?
        
        // Username / nickname
        public var username: String
        
        /// First name
        public var firstname: String
        
        /// Last name
        public var lastname: String
        
        /// Avatar image (gravatar)
        public var avatar: String
        
        /// Date registered
        public var registered: Date
        
        /// User disabled
        public var disabled: Bool
        
        /// Super user
        public var su: Bool
        
        /// Initializer
        required public init(user: User) {
            id = user.id
            username = user.username
            firstname = String(user.firstname.first ?? "?") + "....."
            lastname = user.lastname
            registered = user.registered
            disabled = user.disabled
            su = user.su
            
            let email = user.email
            avatar = email.imageUrlHashFromMail
        }
        
    }
    
    /// Id object
    public struct Id: Content {
        
        /// Id
        public var id: DbCoreIdentifier?
        
        /// Initializer
        public init(id: DbCoreIdentifier) {
            self.id = id
        }
    }
    
    /// Object Id
    public var id: DbCoreIdentifier?
    
    // Username / nickname
    public var username: String
    
    /// First name
    public var firstname: String
    
    /// Last name
    public var lastname: String
    
    /// Email
    public var email: String
    
    /// Verification
    public var verification: String?
    
    /// Password
    public var password: String?
    
    /// Date registered
    public var registered: Date
    
    /// User disabled
    public var disabled: Bool
    
    /// Super user
    public var su: Bool
    
    /// Initializer
    public init(username: String, firstname: String, lastname: String, email: String, verification: String? = nil, password: String? = nil, token: String? = nil, disabled: Bool = true, su: Bool = false) {
        self.username = username
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.verification = verification
        self.password = password
        self.registered = Date()
        self.disabled = disabled
        self.su = su
    }
    
}

// MARK: - Relationships

extension User {
    
    /// Teams relation
    public var teams: Siblings<User, Team, TeamUser> {
        return siblings()
    }
    
}

// MARK: - Migrations

extension User: Migration {
    
    /// Migration preparations
    public static func prepare(on connection: DbCoreConnection) -> Future<Void> {
        return Database.create(self, on: connection) { (schema) in
            schema.field(for: \.id, isIdentifier: true)
            schema.field(for: \.username, type: .varchar(80), .notNull)
            schema.field(for: \.firstname, type: .varchar(80), .notNull)
            schema.field(for: \.lastname, type: .varchar(140), .notNull)
            schema.field(for: \.email, type: .varchar(141), .notNull)
            schema.field(for: \.verification, type: .varchar(64))
            schema.field(for: \.password, type: .varchar(64))
            schema.field(for: \.registered, type: .timestamp, .notNull)
            schema.field(for: \.disabled, type: .bool, .notNull)
            schema.field(for: \.su, type: .bool, .notNull)
        }
    }
    
    /// Migration reverse
    public static func revert(on connection: DbCoreConnection) -> Future<Void> {
        return Database.delete(User.self, on: connection)
    }
    
}


extension User {
    
    /// Convert to displayable object
    public func asDisplay() -> User.Display {
        return User.Display(self)
    }
    
}
