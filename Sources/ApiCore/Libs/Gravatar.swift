//
//  Gravatar.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 09/03/2018.
//

import Foundation
import ErrorsCore
import Vapor


/// Gravatar
public struct Gravatar {
    
    /// Error
    public enum Error: FrontendError {
        
        /// Unable to create MD5 from email
        case unableToCreateMD5FromEmail
        
        public var status: HTTPStatus {
            return .internalServerError
        }
        
        public var identifier: String {
            return "gravatar.unable_create_MD5_from_email"
        }
        
        public var reason: String {
            return "Unable to create MD5 from the given email"
        }
        
    }
    
    /// Generate gravatar link from an email
    public static func link(fromEmail email: String, size: Float? = nil) throws -> String {
        guard let md5 = email.md5 else {
            throw Error.unableToCreateMD5FromEmail
        }
        var url = "https://www.gravatar.com/avatar/\(md5)"
        if let size = size {
            url.append("?size=\(size)")
        }
        return url
    }
    
}
