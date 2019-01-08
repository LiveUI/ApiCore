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
    
    /// Save file from data
    ///
    /// - parameters:
    ///     - file: File data
    ///     - to: Destination path
    ///     - mime: File media type
    ///     - on: Container to execure the operation on
    /// - returns:
    ///     - Future<Void>
    func save(file: Data, to path: String, mime: MediaType, on: Container) throws -> Future<Void>
    
    /// Copy file from local file system
    ///
    /// - parameters:
    ///     - file: Local file path
    ///     - to: Destination path
    ///     - on: Container to execure the operation on
    /// - returns:
    ///     - Future<Void>
    func copy(file: String, to path: String, on: Container) throws -> Future<Void>
    
    /// Move file from local file system
    ///
    /// - parameters:
    ///     - file: Local file path
    ///     - to: Destination path
    ///     - on: Container to execure the operation on
    /// - returns:
    ///     - Future<Void>
    func move(file: String, to path: String, on: Container) throws -> Future<Void>
    
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
    
    
    /// Check if file exists
    ///
    /// - Parameters:
    ///   - file: Path to the file
    ///     - on: Container to execure the operation on
    /// - returns:
    ///     - Future<Bool>
    func exists(file: String, on: Container) throws -> Future<Bool>
    
}

// MARK: - Private helpers

extension FileManagement {
    
    func load(localFile url: URL) throws -> Data? {
        if FileManager.default.fileExists(atPath: url.path) {
            let data = try Data(contentsOf: url)
            return data
        }
        return nil
    }
    
}
