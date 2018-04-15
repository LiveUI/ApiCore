//
//  ErrorLoggingMiddleware.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 11/03/2018.
//

import Foundation
import Async
import Debugging
import HTTP
import Service
import Vapor
import ErrorsCore


final class ErrorLoggingMiddleware: Middleware, Service {
    
    func respond(to req: Request, chainingTo next: Responder) throws -> Future<Response> {
        return try next.respond(to: req).catchFlatMap({ (error) -> (Future<Response>) in
            return ErrorLog(request: req, error: error).save(on: req).flatMap(to: Response.self) { log in
                throw error
            }
        })
    }
    
}
