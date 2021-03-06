//
//  HTTPHeaders+Tools.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 14/01/2018.
//

import Foundation
import Vapor


extension HTTPHeaders {
    
    /// Return value of an authorization header
    /// Stripping any prefix like Token or Bearer
    public var authorizationToken: String? {
        guard let token = self[HTTPHeaderName.authorization].first else {
            return nil
        }
        let parts = token.split(separator: " ")
        guard parts.count == 2 else {
            return nil
        }
        return String(parts[1])
    }
    
}
