//
//  Services+Registration.swift
//  FileCore
//
//  Created by Ondrej Rafaj on 13/05/2018.
//

import Foundation
import Vapor


extension Services {
    
    /// Register FileCoreManager as a service
    public mutating func register(fileCoreManager config: Configuration) throws {
        register(FileCoreManager(config), as: FileCore.self)
    }
    
}
