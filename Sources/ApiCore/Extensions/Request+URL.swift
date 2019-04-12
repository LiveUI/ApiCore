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
        return Me.serverURL()
    }
    
    /// Server's public base URL
    public func serverBaseUrl() -> URL {
        return serverURL().deletingPathExtension()
    }
    
}
