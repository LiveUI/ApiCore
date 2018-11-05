//
//  DebugCheckMiddleware.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 31/10/2018.
//

import Foundation
import Vapor
import ErrorsCore


/// API authentication  middleware
public final class DebugCheckMiddleware: Middleware, Service {
    
    public func respond(to req: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        if req.environment == .production {
            throw ErrorsCore.HTTPError.notAuthorized
        }
        return try next.respond(to: req)
    }
    
    /// Public initializer
    public init() { }
    
}
