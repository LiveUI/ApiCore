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
    
    /// Error alias
    typealias Error = FileCoreManager.Error
    
    /// Configuration
    let config: S3Signer.Config
    
    /// S3 connector
    let s3: S3Client
    
    /// Save file
    public func save(file data: Data, to path: String, mime: MediaType, on container: Container) throws -> EventLoopFuture<Void> {
        let file = File.Upload.init(data: data, destination: path, access: .publicRead, mime: mime.description)
        return try s3.put(file: file, on: container).map(to: Void.self) { response in
            return Void()
        }.catchMap({ error in
            throw Error.failedWriting(path, error)
        })
    }
    
    /// Save local file to an S3 bucket
    func copy(file path: String, to destination: String, on container: Container) throws -> EventLoopFuture<Void> {
        let url = URL(fileURLWithPath: path)
        let data: Data
        do {
            guard let localData = try load(localFile: url) else {
                throw Error.fileNotFound(path)
            }
            data = localData
        } catch {
            throw Error.failedCopy(path, destination, error)
        }
        return try save(file: data, to: destination, mime: (MediaType.fileExtension(url.pathExtension) ?? .plainText), on: container)
    }
    
    /// Move local file to an S3 bucket
    public func move(file path: String, to destination: String, on container: Container) throws -> EventLoopFuture<Void> {
        return try copy(file: path, to: destination, on: container).map(to: Void.self) { void in
            try FileManager.default.removeItem(atPath: path)
            return void
        }
    }
    
    /// Retrieve file
    public func get(file path: String, on container: Container) throws -> EventLoopFuture<Data> {
        return try s3.get(file: path, on: container).map(to: Data.self) { file in
            return file.data
        }.catchMap({ error in
            throw Error.failedReading(path, error)
        })
    }
    
    /// Delete file
    public func delete(file path: String, on container: Container) throws -> EventLoopFuture<Void> {
        return try s3.delete(file: path, on: container).catchMap({ error in
            throw Error.failedRemoving(path, error)
        })
    }
    
    /// Check if file exists
    public func exists(file path: String, on container: Container) throws -> EventLoopFuture<Bool> {
        return try s3.get(file: path, on: container).map(to: Bool.self) { file in
            return true
        }.catchMap({ error in
            return false
        })
    }
    
    /// Initializer
    init(_ config: S3Signer.Config, bucket: String) throws {
        self.config = config
        
        s3 = try S3(defaultBucket: bucket, signer: S3Signer(config)) as S3Client
    }
    
}
