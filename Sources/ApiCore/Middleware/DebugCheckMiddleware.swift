//
//  DebugCheckMiddleware.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 31/10/2018.
//

import Foundation
import Vapor


/// API authentication  middleware
public final class DebugCheckMiddleware: Middleware, Service {
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        fatalError()
    }
    
    /// Public initializer
    public init() { }
    
}
