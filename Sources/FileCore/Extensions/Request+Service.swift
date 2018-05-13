//
//  Request+Service.swift
//  FileCore
//
//  Created by Ondrej Rafaj on 13/05/2018.
//

import Foundation
import Vapor


extension Request {
    
    public func makeFileCore() throws -> FileCore {
        return try make()
    }
    
}
