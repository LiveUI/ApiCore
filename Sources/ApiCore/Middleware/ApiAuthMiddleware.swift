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
    
    /// Respond to method of the middleware
    public func respond(to req: Request, chainingTo next: Responder) throws -> Future<Response> {
        debug(request: req)
        
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
        if req.environment != .production, ApiCoreBase.debugRequests {
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
    
    /// Public initializer
    public init() { }
    
}
