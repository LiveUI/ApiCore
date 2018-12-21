//
//  AuthManager.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 21/12/2018.
//

import Foundation
import Vapor
import FluentPostgreSQL


public class AuthManager {
    
    public static func logout(allFor token: String, on req: Request) throws -> Future<Response> {
        return try get(userFor: token, on: req).flatMap(to: Response.self) { token in
            return try Token.query(on: req).filter(\Token.userId == token.userId).delete().asResponse(to: req)
        }
    }
    
    static func get(userFor token: String, on req: Request) throws -> EventLoopFuture<Token> {
        return try Token.query(on: req).filter(\Token.token == token.sha()).first().flatMap(to: Token.self) { token in
            // Check token exists
            guard let token = token else {
                throw AuthError.authenticationFailed
            }
            // If token is expired, delete and fail authentication
            guard token.expires > Date() else {
                return token.delete(on: req).map(to: Token.self) { _ in
                    throw AuthError.expiredToken
                }
            }
            return req.eventLoop.future(token)
        }
    }
    
    /// Renew token helper
    public static func token(request req: Request, token: String) throws -> Future<Response> {
        return try get(userFor: token, on: req).flatMap(to: Response.self) { token in
            return User.find(token.userId, on: req).flatMap(to: Response.self) { user in
                guard let user = user else {
                    throw AuthError.authenticationFailed
                }
                return try Token.Public(token: token, user: user).asResponse(.ok, to: req).map(to: Response.self) { response in
                    let jwtService = try req.make(JWTService.self)
                    try response.http.headers.replaceOrAdd(name: "Authorization", value: "Bearer \(jwtService.signUserToToken(user: user))")
                    return response
                }
            }
        }
    }
    
    /// Login helper
    public static func login(request req: Request, login: User.Auth.Login) throws -> Future<Response> {
        guard !login.email.isEmpty, !login.password.isEmpty else {
            throw AuthError.authenticationFailed
        }
        return UsersManager.get(user: login.email, password: login.password, on: req).flatMap(to: Response.self) { user in
            guard let user = user else {
                throw AuthError.authenticationFailed
            }
            guard user.verified == true, user.disabled == false else {
                throw AuthError.unverifiedAccount
            }
            
            let token = try Token(user: user, type: .authentication)
            let tokenBackup = token.token
            token.token = try token.token.sha()
            return token.save(on: req).flatMap(to: Response.self) { token in
                guard let _ = token.id else {
                    throw AuthError.serverError
                }
                let publicToken = Token.PublicFull(token: token, user: user)
                publicToken.token = tokenBackup
                return try publicToken.asResponse(.ok, to: req).map(to: Response.self) { response in
                    let jwtService = try req.make(JWTService.self)
                    try response.http.headers.replaceOrAdd(name: "Authorization", value: "Bearer \(jwtService.signUserToToken(user: user))")
                    return response
                }
            }
        }
    }
    
}
