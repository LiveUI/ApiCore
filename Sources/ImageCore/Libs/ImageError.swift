//
//  ImageError.swift
//  ImageCore
//
//  Created by Ondrej Rafaj on 13/05/2018.
//

import Foundation
import ErrorsCore
import Vapor


/// Generic image errors
public enum ImageError: FrontendError {
    
    /// Invalid image format
    case invalidImageFormat
    
    /// Error code
    public var identifier: String {
        switch self {
        case .invalidImageFormat:
            return "imagecore.invalid_image_format"
        }
    }
    
    /// Error desctiption
    public var reason: String {
        switch self {
        case .invalidImageFormat:
            return "Invalid image format"
        }
    }
    
    /// HTTP status code of the error
    public var status: HTTPStatus {
        switch self {
        case .invalidImageFormat:
            return .preconditionFailed
        }
    }
    
}
