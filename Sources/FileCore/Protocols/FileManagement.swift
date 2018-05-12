//
//  FileManagement.swift
//  FileCore
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation
import Vapor


/// Basic file management protocol
public protocol FileManagement {
    
    /// Save file
    func save(file: Data, to path: String, on: Container) throws -> Future<Void>
    
    /// Retrieve file
    func get(file: String, on: Container) throws -> Future<Data>
    
    /// Delete file
    func delete(file: String, on: Container) throws -> Future<Void>
    
}
