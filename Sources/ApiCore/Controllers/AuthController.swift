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
        
        router.get("token") { (req)->Future<Response> in
            guard let tokenString = req.http.headers.authorizationToken else {
                throw AuthError.authenticationFailed
            }
            return try token(request: req, token: tokenString)
        }
        
        router.post("token") { (req) -> Future<Response> in
            return try req.content.decode(User.Auth.Token.self).flatMap(to: Response.self) { (loginData) -> Future<Response> in
                return try token(request: req, token: loginData.token)
            }
        }
        
        router.post("auth", "start-recovery") { (req) -> Future<Response> in
            print("start recovery")
            // read user email from request
            // read redirect url from request
            return try req.content.decode(User.Auth.StartRecovery.self).flatMap(to: Response.self) { (recoveryData) -> Future<Response> in
                // fetch the user by email
                return try User.query(on: req).filter(\User.email == recoveryData.email).first().flatMap(to: Response.self) { (optionalUser) -> Future<Response> in
                    guard let user = optionalUser else {
                        return try req.response.notFound().asFuture(on: req)
                    }

                    let jwtService = try req.make(JWTService.self)
                    let jwtToken = try jwtService.signPasswordReset(user: user, redirectUri: recoveryData.targetUri)

                    // TODO send email
                    let templateModel = User.Auth.RecoveryTemplate(
                        recoveryJwt: jwtToken,
                        user: user
                    )
                    return try PasswordRecoveryTemplate.parsed(model: templateModel, on: req).flatMap(to: Response.self) { template in
                        let from = "ondrej.rafaj@gmail.com"
                        let subject = "password recovery"
                        let mail = Mailer.Message(from: from, to: user.email, subject: subject, text: template.string, html: template.html)
                        return try req.mail.send(mail).flatMap(to: Response.self) { mailResult in
                            switch mailResult {
                            case .success:
                                return try req.response.success(code: "email sent").asFuture(on: req)
                            case .failure(let error):
                                return try req.response.internalServerError(message: error.localizedDescription).asFuture(on: req)
                            default:
                                return try req.response.internalServerError(message: "failed to send email").asFuture(on: req)
                            }
                        }
                    }
                
                }
            }
        }
        
        router.post("auth/finish-recovery") { (req) -> Future<Response> in
            let jwtService: JWTService = try req.make()
            guard let token = req.query.jwt else {
                throw ErrorsCore.HTTPError.notAuthorized
            }
            
            // Get user payload
            guard let resetPayload = try? JWT<JWTPasswordResetPayload>(from: token, verifiedUsing: jwtService.signer).payload else {
                throw ErrorsCore.HTTPError.notAuthorized
            }
            
            try resetPayload.exp.verify()
            return try req.redirect(to: resetPayload.redirectUri).asFuture(on: req)
        }
    }
    
}


extension AuthController {
    
    static func token(request req: Request, token: String) throws -> Future<Response> {
        return try Token.query(on: req).filter(\Token.token == token.passwordHash(req)).first().flatMap(to: Response.self) { token in
            guard let token = token else {
                throw AuthError.authenticationFailed
            }
            return try User.find(token.userId, on: req).flatMap(to: Response.self) { user in
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
    
    static func login(request req: Request, login: User.Auth.Login) throws -> Future<Response> {
        guard !login.email.isEmpty, !login.password.isEmpty else {
            throw AuthError.authenticationFailed
        }
        return try User.query(on: req).filter(\User.email == login.email).filter(\User.password == login.password.passwordHash(req)).first().flatMap(to: Response.self) { user in
            guard let user = user else {
                throw AuthError.authenticationFailed
            }
            let token = try Token(user: user)
            let tokenBackup = token
            token.token = try token.token.passwordHash(req)
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

