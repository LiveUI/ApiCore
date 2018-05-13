//
//  FileCoreManager.swift
//  FileCore
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation
import Vapor
import ErrorsCore


/// Filesystem manager
public class FileCoreManager: FileCore, Service {
    
    /// FileCoreManager errors
    public enum Error: FrontendError {
        
        /// Not implemented
        case notImplemented
        
        /// File not found
        case fileNotFound(String)
        
        /// Error writing file
        case failedWriting(String, Swift.Error)
        
        /// Error copying file
        case failedCopy(String, String, Swift.Error)
        
        /// Error moving file
        case failedMove(String, String, Swift.Error)
        
        /// Error reading file
        case failedReading(String, Swift.Error)
        
        /// Error deleting file
        case failedRemoving(String, Swift.Error)
        
        /// Error code
        public var code: String {
            switch self {
            case .notImplemented:
                return "filecore.not_implemented"
            case .fileNotFound(_):
                return "filecore.not_found"
            case .failedWriting(_, _):
                return "filecore.failed_write"
            case .failedReading(_, _):
                return "filecore.failed_read"
            case .failedRemoving(_, _):
                return "filecore.failed_delete"
            case .failedCopy(_, _, _):
                return "filecore.failed_copy"
            case .failedMove(_, _, _):
                return "filecore.failed_move"
            }
        }
        
        /// Error description
        public var description: String {
            switch self {
            case .notImplemented:
                return "Function not implemented"
            case .fileNotFound(let path):
                return "File not found at path: \(path)"
            case .failedWriting(let path, let error):
                return "Failed writing to file at \(path) with error \(error.localizedDescription)"
            case .failedReading(let path, let error):
                return "Failed reading file at \(path) with error \(error.localizedDescription)"
            case .failedRemoving(let path, let error):
                return "Failed deleting file at \(path) with error \(error.localizedDescription)"
            case .failedCopy(let from, let to, let error):
                return "Failed to copy file from \(from) to \(to) with error \(error.localizedDescription)"
            case .failedMove(let from, let to, let error):
                return "Failed to move file from \(from) to \(to) with error \(error.localizedDescription)"
            }
        }
        
        /// HTTP status code
        public var status: HTTPStatus {
            switch self {
            case .fileNotFound(_):
                return .notFound
            default:
                return .internalServerError
            }
        }
        
    }
    
    /// Filesystem location used in current instance
    public internal(set) var config: Configuration
    
    /// Client for current configuration
    let client: FileManagement
    
    /// Save file from data
    ///
    /// - parameters:
    ///     - file: File data
    ///     - to: Path to the file
    ///     - on: Container to execure the operation on
    /// - returns:
    ///     - Future<Void>
    public func save(file data: Data, to path: String, mime: MediaType, on container: Container) throws -> EventLoopFuture<Void> {
        return try client.save(file: data, to: path, mime: mime, on: container)
    }
    
    /// Copy file from local file system
    ///
    /// - parameters:
    ///     - file: Local file path
    ///     - to: Destination path
    ///     - on: Container to execure the operation on
    /// - returns:
    ///     - Future<Void>
    public func copy(file: String, to path: String, on container: Container) throws -> Future<Void> {
        return try client.copy(file: file, to: path, on: container)
    }
    
    /// Move file from local file system
    ///
    /// - parameters:
    ///     - file: Local file path
    ///     - to: Destination path
    ///     - on: Container to execure the operation on
    /// - returns:
    ///     - Future<Void>
    public func move(file: String, to path: String, on container: Container) throws -> Future<Void> {
        return try client.move(file: file, to: path, on: container)
    }
    
    /// Retrieve file
    ///
    /// - parameters:
    ///     - file: Path to the file
    ///     - on: Container to execure the operation on
    /// - returns:
    ///     - Future<Data>
    public func get(file path: String, on container: Container) throws -> EventLoopFuture<Data> {
        return try client.get(file: path, on: container)
    }
    
    /// Delete file
    ///
    /// - parameters:
    ///     - file: Path to the file
    ///     - on: Container to execure the operation on
    /// - returns:
    ///     - Future<Void>
    public func delete(file path: String, on container: Container) throws -> EventLoopFuture<Void> {
        return try client.delete(file: path, on: container)
    }
    
    /// Initializer
    ///
    /// - parameters:
    ///     - config: FileCoreManager configuration
    public required init(_ config: Configuration) throws {
        self.config = config
        
        switch config {
        case .local(let config):
            client = LocalClient(config)
        case .s3(let config, let bucket):
            client = try S3LibClient(config, bucket: bucket)
        }
    }
    
    
}
