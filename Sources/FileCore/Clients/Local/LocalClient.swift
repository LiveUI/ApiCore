//
//  LocalClient.swift
//  FileCore
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation
import Vapor
import ErrorsCore


/// Local filesystem client
public class LocalClient: FileManagement, Service {
    
    /// Marks if service is remote or local
    public let isRemote: Bool = false
    
    /// Error alias
    typealias Error = FileCoreManager.Error
    
    /// Configuration
    let config: LocalConfig
    
    /// Save file
    public func save(file: Data, to path: String, mime: MediaType, on container: Container) throws -> EventLoopFuture<Void> {
        let url = self.path(file: path)
        let promise = container.eventLoop.newPromise(Void.self)
        Async.dispatchQueue.async {
            do {
                // TODO: Check if destination is a folder and throw if so!!
                let parent = url.deletingLastPathComponent()
                try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true, attributes: nil)
                try file.write(to: url)
                promise.succeed()
            } catch {
                promise.fail(error: Error.failedWriting(url.path, error))
            }
        }
        return promise.futureResult
    }
    
    /// Save file without turning content into data
    public func copy(file path: String, to destination: String, on container: Container) throws -> Future<Void> {
        let promise = container.eventLoop.newPromise(Void.self)
        Async.dispatchQueue.async {
            do {
                // TODO: Check if destination is a folder append the filename to it if so!!
                let destinationUrl = self.path(file: destination)
                let parent = destinationUrl.deletingLastPathComponent()
                try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true, attributes: nil)
                try FileManager.default.copyItem(at: URL(fileURLWithPath: path), to: destinationUrl)
                promise.succeed()
            } catch {
                promise.fail(error: Error.failedCopy(path, destination, error))
            }
        }
        return promise.futureResult
    }
    
    
    /// Move file
    ///
    /// - Parameters:
    ///   - path: String, full path to the original file
    ///   - destination: Local path to the destination
    ///   - container: Event loop / Worker
    /// - Returns: Future
    /// - Throws: Various
    public func move(file path: String, to destination: String, on container: Container) throws -> EventLoopFuture<Void> {
        let promise = container.eventLoop.newPromise(Void.self)
        Async.dispatchQueue.async {
            do {
                // TODO: Check if destination is a folder append the filename to it if so!!
                let destinationUrl = self.path(file: destination)
                let parent = destinationUrl.deletingLastPathComponent()
                try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true, attributes: nil)
                try FileManager.default.moveItem(at: URL(fileURLWithPath: path), to: destinationUrl)
                promise.succeed()
            } catch {
                promise.fail(error: Error.failedMove(path, destination, error))
            }
        }
        return promise.futureResult
    }
    
    
    /// Retrieve file
    ///
    /// - Parameters:
    ///   - path: Local path to the file
    ///   - container: Event loop / Worker
    /// - Returns: Future<Data>
    /// - Throws: Various
    public func get(file path: String, on container: Container) throws -> EventLoopFuture<Data> {
        let url = self.path(file: path)
        let promise = container.eventLoop.newPromise(Data.self)
        Async.dispatchQueue.async {
            do {
                if FileManager.default.fileExists(atPath: url.path) {
                    let data = try Data(contentsOf: url)
                    promise.succeed(result: data)
                } else {
                    promise.fail(error: Error.fileNotFound(url.path))
                }
            } catch {
                promise.fail(error: Error.failedWriting(url.path, error))
            }
        }
        return promise.futureResult
    }
    
    /// Delete file
    public func delete(file path: String, on container: Container) throws -> EventLoopFuture<Void> {
        let url = self.path(file: path)
        let promise = container.eventLoop.newPromise(Void.self)
        Async.dispatchQueue.async {
            do {
                if FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.removeItem(at: url)
                    promise.succeed()
                } else {
                    promise.fail(error: Error.fileNotFound(url.path))
                }
            } catch {
                promise.fail(error: Error.failedWriting(url.path, error))
            }
        }
        return promise.futureResult
    }
    
    /// Check if file exists
    public func exists(file path: String, on container: Container) throws -> EventLoopFuture<Bool> {
        let url = self.path(file: path)
        let promise = container.eventLoop.newPromise(Bool.self)
        Async.dispatchQueue.async {
            let fileExists = FileManager.default.fileExists(atPath: url.path)
            promise.succeed(result: fileExists)
        }
        return promise.futureResult
    }
    
    /// Initializer
    init(_ config: LocalConfig) {
        self.config = config
    }
    
}

// MARK: Private interface

extension LocalClient {
    
    func path(file path: String) -> URL {
        let url = URL(fileURLWithPath: config.root).appendingPathComponent(path)
        return url
    }
    
}
