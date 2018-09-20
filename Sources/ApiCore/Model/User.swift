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
//import DbCore


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
            public var link: String
            
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
            let user = try User(username: username, firstname: firstname, lastname: lastname, email: email, password: password.passwordHash(req), disabled: false, su: false)
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
            public init?(email: String, password: String) throws {
                guard email.count > 3 else {
                    throw AuthError.invalidEmail
                }
                guard try password.validatePassword() else {
                    throw AuthError.invalidPassword(reason: .generic)
                }
                self.email = email
                self.password = password
            }
            
        }
        
        /// Change password
        public struct Password: Content {
            
            /// Password
            public let password: String
            
            /// Initializer (optional)
            public init?(password: String) throws {
                guard try password.validatePassword() else {
                    throw AuthError.invalidPassword(reason: .generic)
                }
                self.password = password
            }
            
        }
        
        /// Token object
        public struct Token: Content {
            
            /// Token
            public let token: String
            
        }
        
        /// URL object
        public struct URI: Content {
            
            /// Target URI to tell client where to redirect
            public let targetUri: String?
            
        }
        
        /// Email confirmation object
        public struct EmailConfirmation: Content {
            
            /// Email
            public let email: String
            
            /// Target URI to tell client where to redirect
            public let targetUri: String?
            
            enum CodingKeys: String, CodingKey {
                case email
                case targetUri = "target"
            }
            
        }
        
        /// Recovery email template object
        public struct RecoveryTemplate: Content {
            
            /// Verification hash (JWT token)
            public let verification: String
            
            /// Recovery validation endpoint link
            public let link: String?
            
            /// User
            public var user: User
            
            /// Finish recovery link
            public var finish: String
            
            /// System wide template data
            public var system: FrontendSystemData
            
            /// Initializer
            ///
            /// - Parameters:
            ///   - verification: Verification token
            ///   - link: Full verification link
            ///   - user: User model
            ///   - req: Request
            /// - Throws: whatever comes it's way
            public init(verification: String, link: String? = nil, user: User, on req: Request) throws {
                self.verification = verification
                self.link = link
                self.user = user
                finish = req.serverURL().absoluteString.finished(with: "/") + "auth/finish-recovery?token=" + verification
                system = try FrontendSystemData(req)
            }
            
        }
        
    }
    
    /// User displayable object
    public final class Display: DbCoreModel {
        
        /// Object Id
        public var id: DbIdentifier?
        
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
        public var id: DbIdentifier?
        
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
        public var id: DbIdentifier?
        
        /// Initializer
        public init(id: DbIdentifier) {
            self.id = id
        }
        
    }
    
    /// Disable object
    public struct Disable: Content {
        
        /// Id
        public var id: DbIdentifier
        
        /// Acccount should be disabled / enable
        public var disable: Bool
        
        /// Initializer
        public init(id: DbIdentifier, disable: Bool) {
            self.id = id
            self.disable = disable
        }
        
    }
    
    /// Object Id
    public var id: DbIdentifier?
    
    // Username / nickname
    public var username: String
    
    /// First name
    public var firstname: String
    
    /// Last name
    public var lastname: String
    
    /// Email
    public var email: String
    
    /// Password
    public var password: String?
    
    /// Date registered
    public var registered: Date
    
    /// User disabled
    public var disabled: Bool
    
    /// User verified
    public var verified: Bool
    
    /// Super user
    public var su: Bool
    
    /// Initializer
    public init(username: String, firstname: String, lastname: String, email: String, password: String? = nil, token: String? = nil, disabled: Bool = true, su: Bool = false) {
        self.username = username
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.password = password
        self.registered = Date()
        self.disabled = disabled
        self.verified = false
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
    public static func prepare(on connection: ApiCoreConnection) -> Future<Void> {
        return Database.create(self, on: connection) { (schema) in
            schema.field(for: \.id, isIdentifier: true)
            schema.field(for: \.username, type: .varchar(80), .notNull)
            schema.field(for: \.firstname, type: .varchar(80), .notNull)
            schema.field(for: \.lastname, type: .varchar(140), .notNull)
            schema.field(for: \.email, type: .varchar(141), .notNull)
            schema.field(for: \.password, type: .varchar(64))
            schema.field(for: \.registered, type: .timestamp, .notNull)
            schema.field(for: \.verified, type: .bool, .notNull)
            schema.field(for: \.disabled, type: .bool, .notNull)
            schema.field(for: \.su, type: .bool, .notNull)
        }
    }
    
    /// Migration reverse
    public static func revert(on connection: ApiCoreConnection) -> Future<Void> {
        return Database.delete(User.self, on: connection)
    }
    
}


extension User {
    
    /// Convert to displayable object
    public func asDisplay() -> User.Display {
        return User.Display(self)
    }
    
}

extension User.Auth.Password {
    
    public func validate() throws -> Bool {
        return try password.validatePassword()
    }
    
}
