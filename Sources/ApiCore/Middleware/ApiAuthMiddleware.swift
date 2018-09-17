//
//  ApiAuthMiddleware.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 13/01/2018.
//

import Foundation
import Async
import Debugging
import HTTP
import Service
import Vapor
import ErrorsCore
import JWT


/// API authentication  middleware
public final class ApiAuthMiddleware: Middleware, Service {
    
    /// Security types
    enum Security: String {
        case unsecured = "Unsecured"
        case secured = "Secured"
        case maintenance = "Maintenance"
    }
    
    /// GET URL's allowed to run without authorization
    public static var allowedGetUri: [String] = [
        // Authentication
        "/auth",
        "/auth/input-recovery",
        "/token",
        "/users/verify",
        
        // Helpers
        "/ping",
        "/teapot",
        
        /// Server info
        "/info",
        "/server/favicon",
        "/server/image",
        "/server/image/16",
        "/server/image/64",
        "/server/image/128",
        "/server/image/192",
        "/server/image/256",
        "/server/image/512",
    ]
    
    /// POST URL's allowed to run without authorization
    public static var allowedPostUri: [String] = [
        // Authentication
        "/auth",
        "/auth/start-recovery",
        "/auth/finish-recovery",
        "/auth/password-check",
        "/token",
        
        // User management
        "/users",
        "/teams/check"
    ]
    
    /// URL's allowed to run only in debug/developement mode
    public static var debugUri: [String] = [
        "/demo",
        "/install",
        "/database",
        "/reinstall",
        "/uninstall"
    ]
    
    /// Respond to method of the middleware
    public func respond(to req: Request, chainingTo next: Responder) throws -> Future<Response> {
        debug(request: req)
        
        // Maintenance URI
        if ApiAuthMiddleware.debugUri.contains(req.http.url.path) {
            self.printUrl(req: req, type: .maintenance)
            if req.environment == .production {
                throw ErrorsCore.HTTPError.notAuthorized
            }
            return try next.respond(to: req)
        }
        
        // Unsecured URI
        if self.allowed(request: req) {
            self.printUrl(req: req, type: .unsecured)
            return try next.respond(to: req)
        }
        
        // Secured
        self.printUrl(req: req, type: .secured)
        
        guard let userPayload = try? jwtPayload(request: req) else {
            return try req.response.notAuthorized().asFuture(on: req)
        }
        
        return User.find(userPayload.userId, on: req).flatMap(to: Response.self) { user in
            guard let user = user else {
                return try req.response.notAuthorized().asFuture(on: req)
            }
            
            let authenticationCache = try req.make(AuthenticationCache.self)
            authenticationCache[User.self] = user
            
            return try next.respond(to: req)
        }
    }
    
    /// Get JWT payload
    private func jwtPayload(request req: Request) throws -> JWTAuthPayload {
        // Get JWT token
        guard let token = req.http.headers.authorizationToken else {
            throw ErrorsCore.HTTPError.notAuthorized
        }
        let jwtService: JWTService = try req.make()
        
        // Get user payload
        guard let userPayload = try? JWT<JWTAuthPayload>(from: token, verifiedUsing: jwtService.signer).payload else {
            throw ErrorsCore.HTTPError.notAuthorized
        }
        
        return userPayload
    }
    
    /// Debug
    private func debug(request req: Request) {
        if ApiCoreBase.debugRequests {
            req.http.body.consumeData(max: 500, on: req).addAwaiter { (d) in
                print("Debugging response:")
                print("HTTP [\(req.http.version.major).\(req.http.version.minor)] with status code [\(req.http)]")
                print("Headers:")
                for header in req.http.headers {
                    print("\t\(header.name.description) = \(header.value)")
                }
                print("Content:")
                if let data = d.result, let s = String(data: data, encoding: .utf8) {
                    print("\tContent:\n\(s)")
                }
            }
        }
    }
    
    /// Is request allowed un-authenticated?
    private func allowed(request req: Request) -> Bool {
        if req.http.method == .GET {
            return ApiAuthMiddleware.allowedGetUri.contains(req.http.url.path)
        } else if req.http.method == .POST {
            return ApiAuthMiddleware.allowedPostUri.contains(req.http.url.path)
        } else if req.http.method == .OPTIONS {
            return true
        }
        return false
    }
    
    /// Print URL
    private func printUrl(req: Request, type: Security) {
        if req.environment != .production {
            print("\(type.rawValue): [\(req.http.method)] \(req.http.url.path)")
        }
    }
    
    /// Public initializer
    public init() { }
    
}
