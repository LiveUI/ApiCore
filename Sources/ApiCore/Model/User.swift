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


/// Can create new user
public protocol UserCreator: Content {
    
    /// Create new user
    func newUser(on req: Request) throws -> User
    
}


/// User object
public final class User: DbCoreModel {
    
    /// Template object
    public struct EmailTemplate: Content {
        
        /// Verification
        public var verification: String
        
        /// Server link
        public var link: String
        
        /// User registration
        public var user: User
        
        /// Sender (for invitations only)
        public var sender: User?
        
    }
    
    /// Registration object
    public struct Registration: UserCreator {
        
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
    
    /// Invitation object
    public struct Invitation: UserCreator {
        
        /// First name
        public var firstname: String
        
        /// Last name
        public var lastname: String
        
        /// Email
        public var email: String
        
        /// Convert to user
        public func newUser(on req: Request) throws -> User {
            let user = User(username: "", firstname: firstname, lastname: lastname, email: email, disabled: false, su: false)
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
            public let value: String
            
            /// Initializer (optional)
            public init?(value: String) throws {
                guard try value.validatePassword() else {
                    throw AuthError.invalidPassword(reason: .generic)
                }
                self.value = value
            }
            
            enum CodingKeys: String, CodingKey {
                case value = "password"
            }
            
        }
        
        /// Username input
        public struct Username: Content {
            
            /// Password
            public let value: String
            
            /// Initializer (optional)
            public init?(value: String) throws {
                self.value = value
            }
            
            enum CodingKeys: String, CodingKey {
                case value = "username"
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
            public let targetUri: String
            
        }
        
        /// Email confirmation object
        public struct EmailConfirmation: Content, EmailRedirects {
            
            /// Email
            public let email: String
            
            /// Target URI for input form
            public let redirectUrl: String
            
            enum CodingKeys: String, CodingKey {
                case email
                case redirectUrl = "redirect"
            }
            
        }
        
        /// Input template data model
        public struct InputTemplate: Content {
            
            /// Template type
            public enum TemplateType {
                
                /// Password recovery
                case passwordRecovery
                
                // Invitation
                case invitation
                
            }
            
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
            ///   - type: Template type (passwordRecovery or invitation)
            ///   - req: Request
            /// - Throws: whatever comes it's way
            public init(verification: String, link: String? = nil, type: TemplateType, user: User, on req: Request) throws {
                self.verification = verification
                self.link = link
                self.user = user
                finish = req.serverURL().absoluteString.finished(with: "/") + "\(type == .passwordRecovery ? "auth/finish-recovery" : "users/finish-invitation")?token=" + verification
                system = try FrontendSystemData(req)
            }
            
        }
        
    }
    
    /// Update input
    public struct Update: Content {
        
        /// First name
        public var firstname: String?
        
        /// Last name
        public var lastname: String?
        
        /// Password
        public var password: String?
        
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
        
        /// User verified
        public var verified: Bool
        
        /// Super user
        public var su: Bool
        
        /// Initializer
        public init(username: String, firstname: String, lastname: String, email: String, disabled: Bool = true, verified: Bool = false, su: Bool = false) {
            self.username = username
            self.firstname = firstname
            self.lastname = lastname
            self.email = email
            self.registered = Date()
            self.disabled = disabled
            self.verified = verified
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
            self.verified = user.verified
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
    
    /// Identify
    public struct Identify: DbCoreModel {
        
        /// Id
        public var id: DbIdentifier?
        
        // Username / nickname
        public var username: String
        
        /// Initializer
        public init(id: DbIdentifier, username: String) {
            self.id = id
            self.username = username
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
    
    /// Return a signed JWT token
    public func asJWTToken(on req: Request) throws -> String {
        let jwtService = try req.make(JWTService.self)
        return try jwtService.signUserToToken(user: self)
    }
    
}

extension User.Auth.Password {
    
    public func validate() throws -> Bool {
        return try value.validatePassword()
    }
    
}
