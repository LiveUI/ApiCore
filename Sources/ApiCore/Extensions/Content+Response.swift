//
//  Content+Response.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 13/02/2018.
//

import Foundation
import Vapor


extension Content {
    
    /// Convert Content to a response
    public func asResponse(_ status: HTTPStatus, to req: Request) throws -> Future<Response> {
        return try encode(for: req).map(to: Response.self) {
            $0.http.status = status
            $0.http.headers.replaceOrAdd(name: HTTPHeaderName.contentType, value: "application/json; charset=utf-8")
            return $0
        }
    }
    
    /// Create and fill object from POST data
    public static func fill(post req: Request) throws -> Future<Self> {
        return try req.content.decode(Self.self)
    }
    
    /// Create and fill object from GET data
    public static func fill(get req: Request) throws -> Self {
        return try req.query.decode(Self.self)
    }
    
}
