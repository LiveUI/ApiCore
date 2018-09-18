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
    
    /// Invalid input value reason
    public enum InvalidInputReason {
        
        /// Generic problem
        case generic
        
        /// Input is too short
        case tooShort
        
        /// Input doesn't match verification value
        case notMatching
        
        /// Needs special characters
        case needsSpecialCharacters
        
        /// Needs numeric values
        case needsNumericCharacters
        
        /// Custom reason
        case custom(String)
        
        /// Reason description
        public var description: String {
            switch self {
            case .generic:
                return "Password is invalid"
            case .tooShort:
                return "Value is too short"
            case .notMatching:
                return "Value doesn't match its verification"
            case .needsSpecialCharacters:
                return "Value needs additional special characters"
            case .needsNumericCharacters:
                return "Value needs numbers"
            case .custom(let message):
                return message
            }
        }
        
    }
    
    /// Authentication has failed
    case authenticationFailed
    
    /// Server error
    case serverError
    
    /// Email is invalid
    case invalidEmail
    
    /// Password is invalid
    case invalidPassword(reason: InvalidInputReason)
    
    /// Invalid token signature
    case invalidToken
    
    /// Account has not been verified yet
    case unverifiedAccount
    
    /// Email already exists
    case emailExists
    
    /// Recovery email failed to be send
    case recoveryEmailFailedToSend
    
    /// Error code
    public var identifier: String {
        switch self {
        case .authenticationFailed, .invalidEmail, .invalidPassword:
            return "auth_error.authentication_failed"
        case .serverError:
            return "auth_error.server_error"
        case .recoveryEmailFailedToSend:
            return "auth.recovery_email_failed"
        case .unverifiedAccount:
            return "auth.unverified_account"
        case .emailExists:
            return "auth.email_exists"
        case .invalidToken:
            return "auth.invalid_recovery_token"
        }
    }
    
    /// HTTP status code for the error
    public var status: HTTPStatus {
        switch self {
        case .authenticationFailed:
            return .unauthorized
        case .invalidEmail, .invalidPassword:
            return .notAcceptable
        case .invalidToken, .unverifiedAccount:
            return .preconditionFailed
        default:
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
        case .invalidPassword(let reason):
            return "Invalid password (\(reason.description))"
        case .recoveryEmailFailedToSend:
            return "Failed to send password recovery email"
        case .unverifiedAccount:
            return "Account has not been verified yet"
        case .emailExists:
            return "Email already exists"
        case .invalidToken:
            return "Invalid recovery token"
        }
    }
    
}
