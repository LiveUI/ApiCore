//
//  S3LibClient.swift
//  FileCore
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation
import Vapor
import S3


/// S3 filesystem client
class S3LibClient: FileManagement, Service {
    
    /// Configuration
    let config: S3Signer.Config
    
    /// S3 connector
    let s3: S3Client
    
    /// Save file
    public func save(file data: Data, to path: String, on container: Container) throws -> EventLoopFuture<Void> {
        let file = File.Upload.init(data: data, destination: path, access: .privateAccess, mime: "mime")
        return try s3.put(file: file, on: container).map(to: Void.self) { response in
            return Void()
        }.catchMap({ error in
            throw FileCoreManager.Error.failedWriting(path, error)
        })
    }
    
    /// Retrieve file
    public func get(file path: String, on container: Container) throws -> EventLoopFuture<Data> {
        return try s3.get(file: path, on: container).map(to: Data.self) { file in
            return file.data
        }.catchMap({ error in
            throw FileCoreManager.Error.failedReading(path, error)
        })
    }
    
    /// Delete file
    public func delete(file path: String, on container: Container) throws -> EventLoopFuture<Void> {
        return try s3.delete(file: path, on: container).catchMap({ error in
            throw FileCoreManager.Error.failedRemoving(path, error)
        })
    }
    
    /// Initializer
    init(_ config: S3Signer.Config, bucket: String) throws {
        self.config = config
        
        self.s3 = try S3(defaultBucket: bucket, signer: S3Signer(config)) as S3Client
    }
    
}
