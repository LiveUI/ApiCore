//
//  AuthController.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 13/01/2018.
//

import Foundation
import Vapor
import FluentPostgreSQL
import DbCore
import Crypto
import ErrorsCore
import Random
import MailCore
import JWT

public class AuthController: Controller {
    
    enum Error: FrontendError {
        
        case recoveryEmailFailedToSend
        
        var status: HTTPStatus {
            return .internalServerError
        }
        
        var identifier: String {
            return "auth.recovery_email_failed"
        }
        
        var reason: String {
            return "Failed to send password recovery email"
        }
        
    }
    
    /// Setup routes
    public static func boot(router: Router) throws {
        // Authenticate with username and password in an Authorization header
        router.get("auth") { (req)->Future<Response> in
            guard let token = req.http.headers.authorizationToken, let decoded = token.base64Decoded else {
                throw AuthError.authenticationFailed
            }
            let parts = decoded.split(separator: ":")
            guard parts.count == 2, let loginData = User.Auth.Login(email: String(parts[0]), password: String(parts[1])) else {
                throw AuthError.authenticationFailed
            }
            return try login(request: req, login: loginData)
        }
        
        // Authenticate with username and password in a POST json
        router.post("auth") { (req)->Future<Response> in
            do {
                return try req.content.decode(User.Auth.Login.self).flatMap(to: Response.self) { loginData in
                    return try login(request: req, login: loginData)
                }
            } catch {
                throw AuthError.authenticationFailed
            }
        }
        
        // Create new JWT token using permanent token (Headers)
        router.get("token") { (req)->Future<Response> in
            guard let tokenString = req.http.headers.authorizationToken else {
                throw AuthError.authenticationFailed
            }
            return try token(request: req, token: tokenString)
        }
        
        // Create new JWT token using permanent token (POST)
        router.post("token") { (req) -> Future<Response> in
            return try req.content.decode(User.Auth.Token.self).flatMap(to: Response.self) { (loginData) -> Future<Response> in
                return try token(request: req, token: loginData.token)
            }
        }
        
        // Forgotten password
        router.post("auth", "start-recovery") { (req) -> Future<Response> in
            // Read user email from request
            // Read redirect url from request
            return try User.Auth.EmailConfirmation.fill(post: req).flatMap(to: Response.self) { recoveryData in
                // Fetch the user by email
                return User.query(on: req).filter(\User.email == recoveryData.email).first().flatMap(to: Response.self) { optionalUser in
                    guard let user = optionalUser else {
                        return try req.response.notFound().asFuture(on: req)
                    }

                    let jwtService = try req.make(JWTService.self)
                    let jwtToken = try jwtService.signEmailConfirmation(
                        user: user,
                        type: .passwordRecovery,
                        redirectUri: recoveryData.targetUri
                    )

                    let templateModel = User.Auth.RecoveryTemplate(
                        verification: jwtToken,
                        link: recoveryData.targetUri ?? "" + "?token=" + jwtToken,
                        user: user
                    )
                    return try PasswordRecoveryEmailTemplate.parsed(model: templateModel, on: req).flatMap(to: Response.self) { template in
                        let from = ApiCoreBase.configuration.mail.email
                        let subject = "Password recovery" // TODO: Localize!!!!!!
                        let mail = Mailer.Message(from: from, to: user.email, subject: subject, text: template.string, html: template.html)
                        return try req.mail.send(mail).flatMap(to: Response.self) { mailResult in
                            switch mailResult {
                            case .success:
                                return try req.response.success(status: .created, code: "auth.recovery_sent", description: "Password recovery email has been sent").asFuture(on: req)
                            default:
                                throw Error.recoveryEmailFailedToSend
                            }
                        }
                    }
                }
            }
        }
        
        router.get("auth/input-recovery") { (req) -> Future<Response> in
            let jwtService: JWTService = try req.make()
            
            guard let token = req.query.token else {
                throw ErrorsCore.HTTPError.notAuthorized
            }
            
            // Get user payload
            guard let resetPayload = try? JWT<JWTConfirmEmailPayload>(from: token, verifiedUsing: jwtService.signer).payload else {
                throw ErrorsCore.HTTPError.notAuthorized
            }
            try resetPayload.exp.verifyNotExpired()
            
            return User.query(on: req).filter(\User.id == resetPayload.userId).first().flatMap(to: Response.self) { user in
                guard let user = user else {
                    throw ErrorsCore.HTTPError.notFound
                }
                
                let templateModel = User.Auth.RecoveryTemplate(
                    verification: token,
                    link: "?token=" + token,
                    user: user
                )
                
                return req.redirect(to: resetPayload.redirectUri).asFuture(on: req)
            }
        }
        
        router.post("auth/finish-recovery") { (req) -> Future<Response> in
            let jwtService: JWTService = try req.make()
            guard let token = req.query.token else {
                throw ErrorsCore.HTTPError.notAuthorized
            }
            
            // Get user payload
            guard let resetPayload = try? JWT<JWTConfirmEmailPayload>(from: token, verifiedUsing: jwtService.signer).payload else {
                throw ErrorsCore.HTTPError.notAuthorized
            }
            
            try resetPayload.exp.verifyNotExpired()
            return req.redirect(to: resetPayload.redirectUri).asFuture(on: req)
        }
    }

}


extension AuthController {
    
    /// Renew token helper
    static func token(request req: Request, token: String) throws -> Future<Response> {
        return try Token.query(on: req).filter(\Token.token == token.sha()).first().flatMap(to: Response.self) { token in
            guard let token = token else {
                throw AuthError.authenticationFailed
            }
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
    static func login(request req: Request, login: User.Auth.Login) throws -> Future<Response> {
        guard !login.email.isEmpty, !login.password.isEmpty else {
            throw AuthError.authenticationFailed
        }
        return User.query(on: req).filter(\User.email == login.email).first().flatMap(to: Response.self) { user in
            guard let user = user, let password = user.password, login.password.verify(against: password) else {
                throw AuthError.authenticationFailed
            }
            let token = try Token(user: user)
            let tokenBackup = token
            token.token = try token.token.sha()
            return token.save(on: req).flatMap(to: Response.self) { token in
                tokenBackup.id = token.id
                
                let publicToken = Token.PublicFull(token: tokenBackup, user: user)
                return try publicToken.asResponse(.ok, to: req).map(to: Response.self) { response in
                    let jwtService = try req.make(JWTService.self)
                    try response.http.headers.replaceOrAdd(name: "Authorization", value: "Bearer \(jwtService.signUserToToken(user: user))")
                    return response
                }
            }
        }
    }
    
}

