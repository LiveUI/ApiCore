//
//  AuthError.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 17/01/2018.
//

import Foundation
import ErrorsCore
import Vapor


// QUESTION: Do we want to bring these in to the HTTPError or generic error in ErrorsCore?
/// Authentication error
public enum AuthError: FrontendError {
    
    /// Authentication has failed
    case authenticationFailed
    
    /// Server error
    case serverError
    
    /// Email is invalid
    case invalidEmail
    
    /// Password is invalid
    case invalidPassword
    
    /// Error code
    public var identifier: String {
        switch self {
        case .authenticationFailed, .invalidEmail, .invalidPassword:
            return "auth_error.authentication_failed"
        case .serverError:
            return "auth_error.server_error"
        }
    }
    
    /// HTTP status code for the error
    public var status: HTTPStatus {
        switch self {
        case .authenticationFailed:
            return .unauthorized
        case .invalidEmail, .invalidPassword:
            return .notAcceptable
        case .serverError:
            return .internalServerError
        }
    }
    
    /// Reason for the error
    public var reason: String {
        switch self {
        case .authenticationFailed:
            return "Authentication has failed"
        case .serverError:
            return "Server error"
        case .invalidEmail:
            return "Invalid email"
        case .invalidPassword:
            return "Invalid password"
        }
    }
}
