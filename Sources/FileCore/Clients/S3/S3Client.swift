//
//  S3Client.swift
//  FileCore
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation
import Vapor
import S3


/// S3 filesystem client
class S3Client: FileManagement, Service {
    
    /// Configuration
    let config: S3Config
    
    /// Save file
    public func save(file: Data, to path: String, on container: Container) throws -> EventLoopFuture<Void> {
        fatalError()
    }
    
    /// Retrieve file
    public func get(file: String, on container: Container) throws -> EventLoopFuture<Data> {
        fatalError()
    }
    
    /// Delete file
    public func delete(file: String, on container: Container) throws -> EventLoopFuture<Void> {
        fatalError()
    }
    
    /// Initializer
    init(_ config: S3Config) {
        self.config = config
    }
    
}
