//
//  Future+Response.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 13/02/2018.
//

import Foundation
import Vapor


extension Future where T: ResponseEncodable {
    
    /// Turn Future into a Future<Response> (.ok by default)
    public func asResponse(_ status: HTTPStatus = .ok, to req: Request) throws -> Future<Response> {
        return self.flatMap(to: Response.self) { try $0.encode(for: req) }.map(to: Response.self) {
            $0.http.status = status
            $0.http.headers.replaceOrAdd(name: HTTPHeaderName.contentType, value: "application/json; charset=utf-8")
            return $0
        }
    }
    
    /// Turn Future into a Future<Response> with text/html Content-Type (.ok by default)
    public func asHtmlResponse(_ status: HTTPStatus = .ok, to req: Request) throws -> Future<Response> {
        return self.flatMap(to: Response.self) { try $0.encode(for: req) }.map(to: Response.self) {
            $0.http.status = status
            $0.http.headers.replaceOrAdd(name: HTTPHeaderName.contentType, value: "text/html; charset=utf-8")
            return $0
        }
    }
    
}

extension Future where T == Void {
    
    /// Turn Future into a Future<Response> (204 - No content)
    public func asResponse(to req: Request) throws -> Future<Response> {
        return self.map(to: Response.self) { _ in
            return try req.response.noContent()
        }
    }
    
}

