//
//  DbError.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 20/09/2018.
//

import Foundation
import Vapor
import ErrorsCore


/// Database error
public enum DbError: FrontendError {
    
    /// Insert operation has failed
    case insertFailed
    
    /// Update operation has failed
    case updateFailed
    
    /// Delete operation has failed
    case deleteFailed
    
    /// Error code
    public var identifier: String {
        switch self {
        case .insertFailed:
            return "db_error.insert_failed"
        case .updateFailed:
            return "db_error.update_failed"
        case .deleteFailed:
            return "db_error.delete_failed"
        }
    }
    
    /// Server status code
    public var status: HTTPStatus {
        return .internalServerError
    }
    
    /// Error reason
    public var reason: String {
        switch self {
        case .insertFailed:
            return "Insert failed"
        case .updateFailed:
            return "Update failed"
        case .deleteFailed:
            return "Delete failed"
        }
    }
    
}
