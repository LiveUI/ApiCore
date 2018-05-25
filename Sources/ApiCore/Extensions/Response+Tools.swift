//
//  Response+Tools.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 09/04/2018.
//

import Foundation
import Vapor


extension Response {
    
    /// Return as a succeeded Future<Response>
    public func asFuture(on req: Request) -> Future<Response> {
        let future = req.eventLoop.newSucceededFuture(result: self)
        return future
    }
    
}


