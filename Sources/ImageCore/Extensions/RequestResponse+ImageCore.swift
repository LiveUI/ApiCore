//
//  RequestResponse+ImageCore.swift
//  ImageCore
//
//  Created by Ondrej Rafaj on 16/05/2018.
//

import Foundation
import ErrorsCore
import Vapor


extension RequestResponse {
    
    /// Basic image response
    ///
    /// - parameters:
    ///     - status: HTTPStatus, default .ok (200)
    ///     - data: Image Data()
    public func image(_ data: Data, status: HTTPStatus = .ok) throws -> Response {
        let response = Response(using: request)
        response.http.status = status
        let mediaType = data.imageFileMediaType()
        let headers = HTTPHeaders([
            ("Content-Type", (mediaType ?? .png).description),
            ("Content-Length", String(data.count)),
            ])
        response.http.headers = headers
        response.http.body = HTTPBody(data: data)
        return response
    }
    
}
