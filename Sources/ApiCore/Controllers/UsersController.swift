//
//  UsersController.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 28/12/2017.
//

import Foundation
import Vapor
import FluentPostgreSQL
import FluentSQL
import MailCore
import ErrorsCore
import JWT


public class UsersController: Controller {
    
    /// Errors for UsersController
    public enum Error: FrontendError {
        
        /// Registrations have been disabled for this instance
        case registrationsNotPermitted
        
        /// Invitations have been disabled for this instance
        case invitationsNotPermitted
        
        /// Registrations have been only enabled for certain domain names
        case domainNotAllowedForRegistration
        
        /// HTTP status code
        public var status: HTTPStatus {
            return .methodNotAllowed
        }
        
        /// Error identifier
        public var identifier: String {
            return "users_error.not_permitted"
        }
        
        /// Reason for failure
        public var reason: String {
            switch self {
            case .registrationsNotPermitted:
                return "Registrations have been disabled"
            case .invitationsNotPermitted:
                return "Invitations have been disabled"
            case .domainNotAllowedForRegistration:
                return "Registrations have been only enabled for certain domain names"
            }
        }
        
    }
    
    /// Setup routes
    public static func boot(router: Router, secure: Router, debug: Router) throws {
        secure.get("users") { req -> Future<[User.Display]> in
            if let search = req.query.search {
                // TODO: MVP! Display only users in my team or within my reach as there are emails available here!!!!!!!!!!!!!!!!!!!!!!!!!!
                return try User.query(on: req).decode(User.Display.self).group(.or) { or in
                    // TODO: Make the search reusable!!
                    or.filter(\User.firstname ~~ search)
                    or.filter(\User.lastname ~~ search)
                    or.filter(\User.email ~~ search)
                    }.paginate(on: req).all()
            } else {
                return try User.query(on: req).decode(User.Display.self).paginate(on: req).all()
            }
        }
        
        secure.get("users", "global") { req -> Future<[User.AllSearch]> in
            if let search = req.query.search {
                return try User.query(on: req).group(.or) { or in
                    or.filter(\User.firstname ~~ search)
                    or.filter(\User.lastname ~~ search)
                    or.filter(\User.email ~~ search)
                    }.paginate(on: req).all().map(to: [User.AllSearch].self) { (users) -> [User.AllSearch] in
                        return users.compactMap { (user) -> User.AllSearch in
                            return User.AllSearch(user: user)
                        }
                }
            } else {
                return try User.query(on: req).paginate(on: req).all().map(to: [User.AllSearch].self) { (users) -> [User.AllSearch] in
                    return users.compactMap { (user) -> User.AllSearch in
                        return User.AllSearch(user: user)
                    }
                }
            }
        }
        
        secure.post("users", "disable") { req -> Future<User> in
            return try User.Disable.fill(post: req).flatMap(to: User.self) { disable in
                return User.query(on: req).filter(\User.id == disable.id).first().flatMap(to: User.self) { user in
                    guard let user = user else {
                        throw ErrorsCore.HTTPError.notFound
                    }
                    // Only an admin can disable users
                    return try req.me.isSystemAdmin().flatMap(to: User.self) { admin in
                        guard admin else {
                            throw ErrorsCore.HTTPError.notAuthorizedAsAdmin
                        }
                        
                        user.disabled = disable.disable
                        return user.save(on: req)
                    }
                }
            }
        }
    
        secure.get("users", "verify") { req -> Future<Response> in
            let jwtService: JWTService = try req.make()
            guard let token = req.query.token else {
                throw ErrorsCore.HTTPError.notAuthorized
            }
            
            // Get user payload
            guard let verifyPayload = try? JWT<JWTConfirmEmailPayload>(from: token, verifiedUsing: jwtService.signer).payload else {
                throw ErrorsCore.HTTPError.notAuthorized
            }
            try verifyPayload.exp.verifyNotExpired()
            guard verifyPayload.type == .registration || verifyPayload.type == .invitation else {
                throw AuthError.invalidToken
            }
            
            return User.query(on: req).filter(\User.id == verifyPayload.userId).first().flatMap(to: Response.self) { user in
                // Validate user
                guard let user = user else {
                    throw ErrorsCore.HTTPError.notFound
                }
                
                // If no error save
                user.verified = true
                
                return user.save(on: req).flatMap(to: Response.self) { user in
                    if !verifyPayload.redirectUri.isEmpty {
                        return req.redirect(to: verifyPayload.redirectUri).asFuture(on: req)
                    } else {
                        let templateModel = try InfoWebTemplate.Model(
                            title: "Success", // TODO: Translate!!!!
                            text: "Your account has been activated",
                            user: user,
                            on: req
                        )
                        let template = try InfoWebTemplate.parsed(.html, model: templateModel, on: req)
                        return try template.asHtmlResponse(.ok, to: req)
                    }
                }
            }
        }
        
        // Registration
        router.post("users") { req -> Future<Response> in
            guard ApiCoreBase.configuration.auth.allowRegistrations == true else {
                throw Error.registrationsNotPermitted
            }
            return try UsersManager.register(req)
        }
        
        // Me
        secure.get("users", "me") { req -> User.Display in
            let user = try req.me.user()
            return user.asDisplay()
        }
        
        // Modify user
        // TODO: TESTS!!!!!!!!!!!!!!!!
        router.put("users", DbIdentifier.parameter) { req -> Future<User.Display> in
            let userId = try req.parameters.next(DbIdentifier.self)
            guard try req.me.user().id == userId else {
                throw ErrorsCore.HTTPError.notAuthorized
            }
            
            return try req.content.decode(User.Update.self).flatMap(to: User.Display.self) { data in
                let user = try req.me.user()
                if let firstname = data.firstname {
                    user.firstname = firstname
                }
                if let lastname = data.lastname {
                    user.lastname = lastname
                }
                if let password = data.password {
                    user.password = try password.passwordHash(req)
                }
                
                return user.save(on: req).map(to: User.Display.self) { user in
                    return user.asDisplay()
                }
            }
        }
        
        // Invitation
        secure.post("users", "invite") { req -> Future<Response> in
            guard ApiCoreBase.configuration.auth.allowInvitations == true else {
                throw Error.invitationsNotPermitted
            }
            return try UsersManager.invite(req)
        }
        
        // Input invitation data
        router.get("users", "input-invite") { req -> Future<Response> in
            let jwtService: JWTService = try req.make()
            
            guard let token = req.query.token else {
                throw ErrorsCore.HTTPError.notAuthorized
            }
            
            // Get user payload
            guard let jwtPayload = try? JWT<JWTConfirmEmailPayload>(from: token, verifiedUsing: jwtService.signer).payload else {
                throw ErrorsCore.HTTPError.notAuthorized
            }
            try jwtPayload.exp.verifyNotExpired()
            guard jwtPayload.type == .invitation else {
                throw AuthError.invalidToken
            }
            
            return User.query(on: req).filter(\User.id == jwtPayload.userId).first().flatMap(to: Response.self) { user in
                guard let user = user else {
                    throw ErrorsCore.HTTPError.notFound
                }
                
                let nick = String(user.email.split(separator: "@")[0])
                user.username = nick
                
                let templateModel = try User.Auth.InputTemplate(
                    verification: token,
                    link: "?token=" + token,
                    type: .invitation,
                    user: user,
                    on: req
                )
                
                let template = try InvitationInputTemplate.parsed(.html, model: templateModel, on: req)
                return try template.asHtmlResponse(.ok, to: req)
            }
        }
        
        // Finish invitation
        router.post("users", "finish-invitation") { req -> Future<Response> in
            let jwtService: JWTService = try req.make()
            guard let token = req.query.token else {
                throw ErrorsCore.HTTPError.notAuthorized
            }
            
            // Get user payload
            guard let jwtPayload = try? JWT<JWTConfirmEmailPayload>(from: token, verifiedUsing: jwtService.signer).payload else {
                throw ErrorsCore.HTTPError.notAuthorized
            }
            try jwtPayload.exp.verifyNotExpired()
            guard jwtPayload.type == .invitation else {
                throw AuthError.invalidToken
            }
            
            return try User.Auth.Username.fill(post: req).flatMap(to: Response.self) { username in
                return try User.Auth.Password.fill(post: req).flatMap(to: Response.self) { password in
                    return User.query(on: req).filter(\User.id == jwtPayload.userId).first().flatMap(to: Response.self) { user in
                        // Validate user
                        guard let user = user else {
                            throw ErrorsCore.HTTPError.notFound
                        }
                        
                        user.username = username.value
                        
                        // Validate new password
                        var passwordError: FrontendError? = nil
                        do {
                            if try !password.validate() {
                                passwordError = AuthError.invalidPassword(reason: .generic)
                            }
                        } catch {
                            passwordError = (error as? FrontendError) ?? AuthError.invalidPassword(reason: .generic)
                        }
                        
                        // If there is no error, save
                        if passwordError == nil {
                            user.password = try password.value.passwordHash(req)
                            user.verified = true
                        }
                        
                        // Save new password
                        return user.save(on: req).flatMap(to: Response.self) { user in
                            if !jwtPayload.redirectUri.isEmpty {
                                return req.redirect(to: jwtPayload.redirectUri).asFuture(on: req)
                            } else {
                                let templateModel = try InfoWebTemplate.Model(
                                    title: "Success", // TODO: Translate!!!!
                                    text: "Your account has been created",
                                    user: user,
                                    //action: InfoWebTemplate.Model.Action(link: "link", title: "title", text: "text"),
                                    on: req
                                )
                                let template = try InfoWebTemplate.parsed(.html, model: templateModel, on: req)
                                return try template.asHtmlResponse(.ok, to: req)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
