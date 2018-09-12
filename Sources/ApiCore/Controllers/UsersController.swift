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


public class UsersController: Controller {
    
    /// Errors
    enum Error: FrontendError {
        
        /// Verification code is missing
        case verificationCodeMissing
        
        /// HTTP error status code
        var status: HTTPStatus {
            return .preconditionFailed
        }
        
        /// Error code
        var identifier: String {
            return "users_controller.verification_code_missing"
        }
        
        /// Reason for failure
        var reason: String {
            return "Verification code is missing"
        }
        
    }
    
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
                return try User.Registration.fill(post: req).flatMap(to: Response.self) { user in
                    let newUser = try user.newUser(on: req)
                    
                    let jwtService = try req.make(JWTService.self)
                    let jwtToken = try jwtService.signEmailConfirmation(
                        user: newUser,
                        type: .registration,
                        redirectUri: emailConfirmation.targetUri,
                        on: req
                    )
                    
                    let templateModel = User.Registration.Template(
                        verification: jwtToken,
                        link: req.serverURL().absoluteString.finished(with: "/") + "users/verify?token=" + jwtToken,
                        user: user
                    )
                    return try RegistrationTemplate.parsed(model: templateModel, on: req).flatMap(to: Response.self) { double in
                        let from = ApiCoreBase.configuration.mail.email
                        let subject = "Registration" // TODO: Localize!!!!!!
                        let mail = Mailer.Message(from: from, to: user.email, subject: subject, text: double.string, html: double.html)
                        return try req.mail.send(mail).flatMap(to: Response.self) { mailResult in
                            return newUser.save(on: req).flatMap(to: Response.self) { user in
                                return try user.asDisplay().asResponse(.created, to: req)
                            }
                        }
                    }
                }
            }
        }
        
        router.get("users", "verify") { (req) -> Future<Response> in
            fatalError()
        }
    }
    
}
