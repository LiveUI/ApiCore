//
//  Request+URL.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 22/02/2018.
//

import Foundation
import Vapor


extension Request {
    
    /// Server's public URL
    public func serverURL() -> URL {
        let stringUrl = ApiCoreBase.configuration.server.url ?? http.headers["X-Forwarded-Proto"].first ?? "http://localhost:8080"
        guard let url = URL(string: stringUrl) else {
            fatalError("Invalid server URL: \(stringUrl)")
        }
        return url
    }
    
    /// Server's public base URL
    public func serverBaseUrl() -> URL {
        return serverURL().deletingPathExtension()
    }
    
}
