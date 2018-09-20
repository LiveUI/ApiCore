//
//  Token.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 13/01/2018.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
//import DbCore
import ErrorsCore
import Random


/// Tokens array type typealias
public typealias Tokens = [Token]


/// Token object
public final class Token: DbCoreModel {
    
    /// Token type
    public enum TokenType: String, PostgreSQLRawEnum {
        
        /// Authentication
        case authentication = "auth"
        
        /// All available cases
        public static var allCases: [TokenType] {
            return [
                .authentication
            ]
        }

    }
    
    /// Error
    public enum Error: FrontendError {
        
        /// User Id is missing
        case missingUserId
        
        /// HTTP status
        public var status: HTTPStatus {
            return .preconditionFailed
        }
        
        /// Error identifier
        public var identifier: String {
            return "token.missing_user_id"
        }
        
        /// Reason for failure
        public var reason: String {
            return "User ID is missing"
        }
        
    }
    
    /// Displayable full public object
    /// for security reasons, the original object should never be displayed
    public final class PublicFull: DbCoreModel {
        
        /// Object id
        public var id: DbIdentifier?
        
        /// User
        public var user: User.Display
        
        /// Token
        public var token: String
        
        /// Token expiry date
        public var expires: Date
        
        /// Token type
//        public var type: TokenType
        
        /// Initializer
        public init(token: Token, user: User) {
            self.id = token.id
            self.user = User.Display(user)
            self.token = token.token
            self.expires = token.expires
//            self.type = token.type
        }
    }
    
    public final class PublicNoUser: DbCoreModel {
        
        /// Object id
        public var id: DbIdentifier?
        
        /// Token
        public var token: String
        
        /// Token expiry time
        public var expires: Date
        
        /// Token type
//        public var type: TokenType
        
        /// Initializer
        public init(token: Token) {
            self.id = token.id
            self.token = token.token
            self.expires = token.expires
//            self.type = token.type
        }
    }
    
    /// Displayable public object
    /// for security reasons, the original object should never be displayed
    public final class Public: DbCoreModel {
        
        /// Object id
        public var id: DbIdentifier?
        
        /// User
        public var user: User.Display
        
        /// Token expiry date
        public var expires: Date
        
        /// Initializer
        public init(token: Token, user: User) {
            self.id = token.id
            self.user = User.Display(user)
            self.expires = token.expires
        }
    }
    
    /// Object id
    public var id: DbIdentifier?
    
    /// User Id
    public var userId: DbIdentifier
    
    /// Token
    public var token: String
    
    /// Token expiry date
    public var expires: Date
    
    /// Token type
//    public var type: TokenType
    
    /// Initializer
    init(user: User, type: TokenType) throws {
        guard let userId = user.id else {
            throw Error.missingUserId
        }
        self.userId = userId
        let randData = try URandom().generateData(count: 60)
        let rand = randData.base64EncodedString()
        self.token = String(rand.prefix(60))
        self.expires = Date().addMonth(n: 1)
//        self.type = type
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case token
        case expires
//        case type
    }

}

// MARK: - Migrations

extension Token: Migration {
    
    /// Migration preparations
    public static func prepare(on connection: ApiCoreConnection) -> Future<Void> {
        return Database.create(self, on: connection) { (schema) in
            schema.field(for: \.id, isIdentifier: true)
            schema.field(for: \.userId, type: .uuid, .notNull)
            schema.field(for: \.token, type: .varchar(64), .notNull)
            schema.field(for: \.expires, type: .timestamp, .notNull)
//            schema.field(for: \.type, type: .varchar(4), .notNull)
        }
    }
    
    /// Migration reverse
    public static func revert(on connection: ApiCoreConnection) -> Future<Void> {
        return Database.delete(Token.self, on: connection)
    }
    
}

