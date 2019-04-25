//
//  Auth.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 25/04/2019.
//

import Foundation
import Vapor
import ErrorsCore


public final class Auth: Controller {
    
    public enum Error<A>: FrontendError where A: Authenticable {
        
        case missingRedirectLink
        case unableToProcessUserData
        case unableToGenerateRedirectLink
        
        public var status: HTTPStatus {
            switch self {
            case .missingRedirectLink:
                return .badRequest
            case .unableToProcessUserData, .unableToGenerateRedirectLink:
                return .internalServerError
            }
        }
        
        public var identifier: String {
            switch self {
            case .missingRedirectLink:
                return "\(A.name.lowercased()).missing_redirect_link"
            case .unableToProcessUserData:
                return "\(A.name.lowercased()).bad_user_data"
            case .unableToGenerateRedirectLink:
                return "\(A.name.lowercased()).callback_link_error"
            }
        }
        
        public var reason: String {
            switch self {
            case .missingRedirectLink:
                return "Missing redirect link"
            case .unableToProcessUserData:
                return "Unable to process user data"
            case .unableToGenerateRedirectLink:
                return "Unable to generate the redirect link"
            }
        }
        
    }
    
    static var authenticators: [Authenticable.Type] = []
    
    static func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
        for auth in authenticators {
            try auth.configure(&config, &env, &services)
        }
    }
    
    /// Boot routes for all available authenticators
    public static func boot(router: Router, secure: Router, debug: Router) throws {
        for auth in authenticators {
            try auth.boot(router: router, secure: secure, debug: debug)
        }
    }
    
    /// Return authenticated user details back to the system for authentication
    ///
    /// - Parameters:
    ///   - user: Information about the user from the service
    ///   - redirectUrl: Redirect URL (usually kept in a session when user is redirected from a website)
    ///   - auth: Original authenticator service type
    ///   - req: Request
    /// - Returns: Redirect to the desired frontend url with JWT signed data
    /// - Throws: FrontendError
    public static func authenticate<T>(_ user: Authenticated, redirectUrl: URL, with auth: T, on req: Request) throws -> EventLoopFuture<ResponseEncodable> where T: Authenticable {
        return try UsersManager.userFromExternalAuthenticationService(user, on: req).flatMap(to: ResponseEncodable.self) { apiCoreUser in
            return try AuthManager.authData(request: req, user: apiCoreUser).map(to: ResponseEncodable.self) { authData in
                var user = user
                user.token = authData.0.token
                guard let url = try? redirectUrl.append(userInfo: user, on: req), let unwrappedUrl = url else {
                    throw Error<T>.unableToGenerateRedirectLink
                }
                
                return req.redirect(to: unwrappedUrl.absoluteString)
            }
        }
    }
    
    /// Register new authenticator with the system
    public static func add(authenticator: Authenticable.Type) throws {
        authenticators.append(authenticator)
    }
    
}
