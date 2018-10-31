//
//  UrlPrinterMiddleware.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 31/10/2018.
//

import Foundation
import Vapor


/// API authentication  middleware
public final class UrlPrinterMiddleware: Middleware, Service {
    
    public func respond(to req: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        print("[\(req.http.method)] \(req.http.url.path)")
        
        return try next.respond(to: req)
    }
    
    /// Public initializer
    public init() { }
    
}
