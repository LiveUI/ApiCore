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
    
    /// Setup routes
    public static func boot(router: Router) throws {
        router.get("users") { (req) -> Future<[User.Display]> in
            if let search = req.query.search {
                // TODO: Display only users in my team or within my reach as there are emails available here!!!!!!!!!!
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
        
        router.get("users", "global") { (req) -> Future<[User.AllSearch]> in
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
        
        router.post("users") { (req) -> Future<Response> in
            return try User.Auth.EmailConfirmation.fill(post: req).flatMap(to: Response.self) { emailConfirmation in
                return try User.Registration.fill(post: req).flatMap(to: Response.self) { registrationData in
                    return User.query(on: req).filter(\User.email == registrationData.email).first().flatMap(to: Response.self) { existingUser in
                        guard existingUser == nil else {
                            throw AuthError.emailExists
                        }
                        
                        let newUser = try registrationData.newUser(on: req)
                        
                        // Save new user
                        return newUser.save(on: req).flatMap(to: Response.self) { user in
                            let jwtService = try req.make(JWTService.self)
                            let jwtToken = try jwtService.signEmailConfirmation(
                                user: user,
                                type: .registration,
                                redirectUri: emailConfirmation.targetUri,
                                on: req
                            )
                            
                            // TODO: Add base64 encoded server image to the template!!!
                            let templateModel = User.Registration.Template(
                                verification: jwtToken,
                                link: req.serverURL().absoluteString.finished(with: "/") + "users/verify?token=" + jwtToken,
                                user: registrationData
                            )
                            return try RegistrationTemplate.parsed(model: templateModel, on: req).flatMap(to: Response.self) { double in
                                let from = ApiCoreBase.configuration.mail.email
                                let subject = "Registration" // TODO: Localize!!!!!!
                                let mail = Mailer.Message(from: from, to: registrationData.email, subject: subject, text: double.string, html: double.html)
                                return try req.mail.send(mail).flatMap(to: Response.self) { mailResult in
                                    switch mailResult {
                                    case .success:
                                        return try user.asDisplay().asResponse(.created, to: req)
                                    default:
                                        throw AuthError.recoveryEmailFailedToSend
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        router.get("users", "verify") { (req) -> Future<Response> in
            let jwtService: JWTService = try req.make()
            guard let token = req.query.token else {
                throw ErrorsCore.HTTPError.notAuthorized
            }
            
            // Get user payload
            guard let verifyPayload = try? JWT<JWTConfirmEmailPayload>(from: token, verifiedUsing: jwtService.signer).payload else {
                throw ErrorsCore.HTTPError.notAuthorized
            }
            try verifyPayload.exp.verifyNotExpired()
            guard verifyPayload.type == .registration else {
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
