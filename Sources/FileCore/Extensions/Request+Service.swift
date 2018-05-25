//
//  Request+Service.swift
//  FileCore
//
//  Created by Ondrej Rafaj on 13/05/2018.
//

import Foundation
import Vapor


extension Request {
    
    /// Make file core instance
    public func makeFileCore() throws -> CoreManager {
        return try make()
    }
    
}
