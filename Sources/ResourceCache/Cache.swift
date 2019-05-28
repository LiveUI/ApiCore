//
//  Cache.swift
//  ResourceCache
//
//  Created by Ondrej Rafaj on 28/05/2019.
//

import Foundation
import Vapor


public class Cache: Service {
    
    public enum Error: Debuggable {
        
        case resourceNotFound
        
        case invalidUrl
        
        public var identifier: String {
            switch self {
            case .resourceNotFound:
                return "resource_cache.not_found"
            case .invalidUrl:
                return "resource_cache.invalid URL"
            }
        }
        
        public var reason: String {
            switch self {
            case .resourceNotFound:
                return "Resource has not been found"
            case .invalidUrl:
                return "Invalid URL"
            }
        }
        
    }
    
    public struct Config {
        
        public let storagePath: String
        
        public init(storagePath: String) {
            self.storagePath = storagePath
        }
        
    }
    
    public let config: Config
    
    public init(_ config: Config) {
        self.config = config
    }
    
    // MARK: Class interface
    
    public func get(url: URL, on req: Request) throws -> EventLoopFuture<String> {
        guard let value = saved(file: url) else {
            let client = try req.make(Client.self)
            return client.get(url).flatMap({ response in
                return response.http.body.consumeData(max: 5_000_000, on: req).map({ [weak self] data in
                    guard let value = String(data: data, encoding: .utf8) else {
                        throw Error.resourceNotFound
                    }
                    try self?.save(content: value, from: url, on: req)
                    return value
                })
            })
        }
        return req.eventLoop.newSucceededFuture(result: value)
    }
    
    public func get(url: String, on req: Request) throws -> EventLoopFuture<String> {
        guard let url = URL(string: url) else {
            throw Error.invalidUrl
        }
        return try get(url: url, on: req)
    }
    
    // MARK: Private interface
    
    func saved(file url: URL) -> String? {
        guard let data = try? Data(contentsOf: file(path: url)) else {
            return nil
        }
        let string = String(data: data, encoding: .utf8)
        return string
    }
    
    func safe(text: String) -> String {
        var text = text.components(separatedBy: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_-").inverted).joined(separator: "-").lowercased()
        text = text.components(separatedBy: CharacterSet(charactersIn: "-")).filter { !$0.isEmpty }.joined(separator: "-")
        return text
    }
    
    func file(name url: URL) -> String {
        return safe(text: url.absoluteString).finished(with: ".").appending("cache")
    }
    
    func file(path url: URL) -> URL {
        let fileName = file(name: url)
        let path = URL(fileURLWithPath: config.storagePath).appendingPathComponent(fileName)
        return path
    }
    
    func save(content: String, from url: URL, on req: Request) throws {
        let path = file(path: url)
        try content.write(to: path, atomically: true, encoding: .utf8)
    }
    
}
