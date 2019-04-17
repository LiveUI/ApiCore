//
//  Response+Encoding.swift
//  Templator
//
//  Created by Ondrej Rafaj on 16/04/2019.
//

import Foundation
import Vapor


extension Response {
    
    static func encode<Data>(json data: Data?, status: HTTPStatus = .ok, headers: [(String, String)] = [], on req: Request) throws -> Response where Data: Encodable {
        var newHeaders = HTTPHeaders(
            [
                ("Content-Type", "application/json; charset=utf-8")
            ]
        )
        for header in headers {
            newHeaders.add(name: header.0, value: header.1)
        }
        guard let data = data else {
            return Response(
                http: HTTPResponse(
                    status: .notFound,
                    headers: newHeaders,
                    body: try JSONEncoder().encode(NotFound())
                ),
                using: req
            )
        }
        return Response(
            http: HTTPResponse(
                status: status,
                headers: newHeaders,
                body: try JSONEncoder().encode(data)
            ),
            using: req
        )
    }
    
}
