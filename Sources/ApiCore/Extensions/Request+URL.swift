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
        let stringUrl = ApiCoreBase.configuration.server.url ?? "http://localhost:8080"
        guard var url = URL(string: stringUrl) else {
            fatalError("Invalid server URL: \(stringUrl)")
        }
        if let prefix = ApiCoreBase.configuration.server.pathPrefix, !prefix.isEmpty {
            url.appendPathComponent(prefix)
        }
        return url
    }
    
    /// Server's public base URL
    public func serverBaseUrl() -> URL {
        return serverURL().deletingPathExtension()
    }
    
}
