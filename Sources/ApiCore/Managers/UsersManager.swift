//
//  UsersManager.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 21/12/2018.
//

import Foundation
import Vapor
import FluentPostgreSQL
import ErrorsCore
import MailCore


public protocol EmailRedirects {
    var linkUrl: String { get }
}


public class UsersManager {
    
    public static func userFromExternalAuthenticationService(_ source: UserSource, on req: Request) throws -> EventLoopFuture<User> {
        return User.query(on: req).filter(\User.email == source.email).first().flatMap(to: User.self) { user in
            guard let user = user else {
                let user = try source.asUser(on: req)
                user.verified = true
                user.disabled = false
                return user.save(on: req).map(to: User.self) { _ in
                    return user
                }
            }
            return req.eventLoop.newSucceededFuture(result: user)
        }
    }
    
    public static func get(user email: String, password: String, on req: Request) -> EventLoopFuture<User?> {
        return User.query(on: req).filter(\User.email == email).first().map(to: User?.self) { user in
            guard let user = user, let userPassword = user.password, password.verify(against: userPassword) else {
                return nil
            }
            return user
        }
    }
    
    public static func checkDomain(email: String, for allowedDomains: [String]) throws {
        if !allowedDomains.isEmpty {
            guard let domain = email.domainFromEmail(), !domain.isEmpty else {
                throw UsersController.Error.domainNotAllowedForRegistration
            }
            guard allowedDomains.contains(domain) else {
                throw UsersController.Error.domainNotAllowedForRegistration
            }
        }
    }
    
    public static func checkExistingUser(email: String, on req: Request) -> Future<User?> {
        return User.query(on: req).filter(\User.email == email).first().map(to: User?.self) { existingUser in
            guard let existingUser = existingUser else {
                return nil
            }
            return existingUser
        }
    }
    
    public static func save(_ user: User, redirects: EmailRedirects, isInvite: Bool, on req: Request) throws -> Future<User> {
        return user.save(on: req).flatMap(to: User.self) { user in
            let jwtService = try req.make(JWTService.self)
            let jwtToken = try jwtService.signEmailConfirmation(
                user: user,
                type: (isInvite ? .invitation : .registration),
                redirects: redirects,
                on: req
            )
            
            // TODO: Add base64 encoded server image to the template!!!
            let templateModel = try User.EmailTemplate(
                verification: jwtToken,
                link: redirects.linkUrl + "?token=" + jwtToken,
                sender: isInvite ? req.me.user() : nil
            )
            return try templateModel.setup(user: user.asDisplay(), on: req).flatMap() { _ in
                let templator = try req.make(Templator.self)
                let template = isInvite ? "invitation" : "registration"
                let htmlFuture = try templator.get(name: "email.\(template).html", data: templateModel, on: req)
                let plainFuture = try templator.get(name: "email.\(template).plain", data: templateModel, on: req)
                
                return htmlFuture.flatMap(to: User.self) { htmlTemplate in
                    return plainFuture.flatMap(to: User.self) { plainTemplate in
                        let from = ApiCoreBase.configuration.mail.email
                        let subject = isInvite ? "Invitation" : "Registration" // TODO: Localize!!!!!!
                        let mail = Mailer.Message(from: from, to: user.email, subject: subject, text: plainTemplate, html: htmlTemplate)
                        return try req.mail.send(mail).map(to: User.self) { mailResult in
                            switch mailResult {
                            case .success:
                                return user
                            default:
                                throw AuthError.emailFailedToSend
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static func invite(_ req: Request) throws -> Future<Response> {
        if !ApiCoreBase.configuration.auth.allowedDomainsForInvitations.isEmpty {
            guard ApiCoreBase.configuration.auth.allowInvitations else {
                throw UsersController.Error.invitationsNotPermitted
            }
        }
        return try User.Auth.EmailConfirmation.fill(post: req).flatMap(to: Response.self) { emailConfirmation in
            try checkDomain(
                email: emailConfirmation.email,
                for: ApiCoreBase.configuration.auth.allowedDomainsForInvitations
            ) // Check if domain is allowed in the system
            
            return try User.Invitation.fill(post: req).flatMap(to: Response.self) { data in
                return checkExistingUser(email: data.email, on: req).flatMap(to: Response.self) { existingUser in
                    let user: User
                    if let existingUser = existingUser {
                        if existingUser.verified == true {
                            // QUESTION: Do we want a more specific error? In this case no need to re-send invite as user is already registered
                            throw AuthError.emailExists
                        } else {
                            user = existingUser
                        }
                    } else {
                        user = try data.newUser(on: req)
                    }
                    
                    if ApiCoreBase.configuration.general.singleTeam == true { // Single team scenario
                        return Team.adminTeam(on: req).flatMap(to: Response.self) { singleTeam in
                            return try save(user, redirects: emailConfirmation, isInvite: true, on: req).flatMap(to: Response.self) { newUser in
                                return singleTeam.users.attach(newUser, on: req).flatMap(to: Response.self) { _ in
                                    return try newUser.asDisplay().asResponse(.created, to: req)
                                }
                            }
                        }
                    } else {
                        return try save(user, redirects: emailConfirmation, isInvite: true, on: req).flatMap(to: Response.self) { user in
                            return try user.asDisplay().asResponse(.created, to: req)
                        }
                    }
                }
            }
        }
    }
    
    public static func register(_ req: Request) throws -> Future<Response> {
        return try User.Auth.EmailConfirmation.fill(post: req).flatMap(to: Response.self) { emailConfirmation in
            try checkDomain(
                email: emailConfirmation.email,
                for: ApiCoreBase.configuration.auth.allowedDomainsForRegistration
            ) // Check if domain is allowed in the system
            
            return try User.Registration.fill(post: req).flatMap(to: Response.self) { data in
                return checkExistingUser(email: data.email, on: req).flatMap(to: Response.self) { user in
                    guard user == nil else {
                        throw AuthError.emailExists
                    }
                    let user = try data.newUser(on: req)
                    
                    if ApiCoreBase.configuration.general.singleTeam == true { // Single team scenario
                        return Team.adminTeam(on: req).flatMap(to: Response.self) { singleTeam in
                            return try save(user, redirects: emailConfirmation, isInvite: false, on: req).flatMap(to: Response.self) { newUser in
                                return singleTeam.users.attach(newUser, on: req).flatMap(to: Response.self) { _ in
                                    return try newUser.asDisplay().asResponse(.created, to: req)
                                }
                            }
                        }
                    } else {
                        return try save(user, redirects: emailConfirmation, isInvite: false, on: req).flatMap(to: Response.self) { user in
                            return try user.asDisplay().asResponse(.created, to: req)
                        }
                    }
                }
            }
        }
    }
    
}
