//
//  AuthenticationCache.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 18/01/2018.
//

import Foundation
import Vapor
import DbCore
import JWT


/// JWT payload object
struct JWTAuthPayload: JWTPayload {
    
    /// Expiration
    var exp: ExpirationClaim
    
    /// User Id
    var userId: UUID
    
    enum CodingKeys: String, CodingKey {
        case exp
        case userId = "user_id"
    }
    
    /// Verify
    func verify() throws {
        try exp.verify()
    }
}

struct JWTPasswordResetPayload: JWTPayload {
    
    var exp: ExpirationClaim
    var userId: UUID
    var redirectUri: String

    enum CodingKeys: String, CodingKey {
        case exp
        case userId = "user_id"
        case redirectUri = "redirect_uri"
    }
    
    func verify() throws {
        try exp.verify()
    }
}


/// JWT service
final class JWTService: Service {
    
    /// Seconds in one minute
    let minute: TimeInterval = 60

    /// Seconds in an hour
    let hour: TimeInterval = 3600
    
    /// Signer
    var signer: JWTSigner
    
    /// Initializer
    init(secret: String) {
        signer = JWTSigner.hs512(key: Data(secret.utf8))
    }
    
    /// Sign user to token
    func signUserToToken(user: User) throws -> String {
        let exp = ExpirationClaim(value: Date(timeIntervalSinceNow: (15 * minute)))
        var jwt = JWT(payload: JWTAuthPayload(exp: exp, userId: user.id!))
        
        jwt.header.typ = nil // set to nil to avoid dictionary re-ordering causing probs
        let data = try signer.sign(&jwt)
        
        guard let jwtToken: String = String(data: data, encoding: .utf8) else {
            throw AuthError.serverError
        }
        return jwtToken
    }
    
    func signPasswordReset(user: User, redirectUri: String) throws -> String {
        let exp = ExpirationClaim(value: Date(timeIntervalSinceNow: (36 * hour)))
        var jwt = JWT(payload: JWTPasswordResetPayload(exp: exp, userId: user.id!, redirectUri: redirectUri))
        
        jwt.header.typ = nil // set to nil to avoid dictionary re-ordering causing probs
        let data = try signer.sign(&jwt)
        
        guard let jwtToken: String = String(data: data, encoding: .utf8) else {
            throw AuthError.serverError
        }
        return jwtToken
    }
    
}


/// Authentication cache service
final class AuthenticationCache: Service {
    
    /// The internal storage.
    private var storage: [ObjectIdentifier: Any]
    
    /// Create a new authentication cache.
    init() {
        self.storage = [:]
    }
    
    /// Access the cache using types.
    internal subscript<A>(_ type: A.Type) -> A? {
        get {
            return storage[ObjectIdentifier(A.self)] as? A
        }
        set {
            storage[ObjectIdentifier(A.self)] = newValue
        }
    }
    
}

extension Request {
    
    /// Authenticates the supplied instance for this request.
    public func authenticate<A>(_ instance: A) throws {
        let cache = try privateContainer.make(AuthenticationCache.self)
        cache[A.self] = instance
    }
    
    /// Returns the authenticated instance of the supplied type.
    /// note: nil if no type has been authed, throws if there is a problem.
    public func authenticated<A>(_ type: A.Type) throws -> A? {
        let cache = try privateContainer.make(AuthenticationCache.self)
        return cache[A.self]
    }
    
    /// Returns true if the type has been authenticated.
    public func isAuthenticated<A>(_ type: A.Type) throws -> Bool {
        return try authenticated(A.self) != nil
    }
    
    /// Returns an instance of the supplied type. Throws if no
    /// instance of that type has been authenticated or if there
    /// was a problem.
    public func requireAuthenticated<A>(_ type: A.Type) throws -> A {
        guard let auth = try authenticated(A.self) else {
            throw Abort(.unauthorized, reason: "\(A.self) has not been authenticated.")
        }
        return auth
    }
    
}
