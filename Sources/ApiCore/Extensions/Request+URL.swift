//
//  Request+URL.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 22/02/2018.
//

import Foundation
import Vapor


extension Request {
    
    public func serverURL() -> URL {
        let stringUrl = Environment.get("SERVER_URL") ?? http.headers["X-Forwarded-Proto"].first ?? "http://localhost:8080"
        guard let url = URL(string: stringUrl) else {
            fatalError("Invalid server URL: \(stringUrl)")
        }
        return url
    }
    
    public func serverBaseUrl() -> URL {
        return serverURL().deletingPathExtension()
    }
    
}
