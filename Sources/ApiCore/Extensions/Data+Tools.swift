//
//  Data+Tools.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 11/09/2018.
//

import Foundation
import Vapor


extension Data {
    
    public func asUTF8String() -> String? {
        return String(data: self, encoding: .utf8)
    }
    
}


extension EventLoopFuture where T == Data {
    
    public func mapToImageResponse(on req: Request) -> EventLoopFuture<Response> {
        return self.map(to: Response.self) { data in
            let response = try req.response.image(data)
            return response
        }
    }
    
}
