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
    ///
    /// - parameters:
    ///     - file: File data
    ///     - to: Path to the file
    ///     - on: Container to execure the operation on
    /// - returns:
    ///     - Future<Void>
    func save(file: Data, to path: String, on: Container) throws -> Future<Void>
    
    /// Retrieve file
    ///
    /// - parameters:
    ///     - file: Path to the file
    ///     - on: Container to execure the operation on
    /// - returns:
    ///     - Future<Data>
    func get(file: String, on: Container) throws -> Future<Data>
    
    /// Delete file
    ///
    /// - parameters:
    ///     - file: Path to the file
    ///     - on: Container to execure the operation on
    /// - returns:
    ///     - Future<Void>
    func delete(file: String, on: Container) throws -> Future<Void>
    
}
