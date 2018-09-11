//
//  FrontendSystemData.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 11/09/2018.
//

import Foundation
import Vapor


/// Model object containing data for frontend web templates
public struct FrontendSystemData: Content {
    
    /// Server URL
    public var info: Info
    
    enum CodingKeys: String, CodingKey {
        case info = "info"
    }
    
    /// Initializer
    ///
    /// - Parameter req: Request
    /// - Throws: something ... from time to time
    public init(_ req: Request) throws {
        info = try Info(req)
    }
    
}
