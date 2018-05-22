//
//  Configurable.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 22/05/2018.
//

import Foundation
import Vapor


/// Configurable
public protocol Configurable: Codable { }


extension Configurable {
    
    /// Load String property from env
    func load(_ key: String, to property: inout String) {
        if let value = self.property(key: key) {
            property = value
        }
    }
    
    /// Load optional String property from env
    func load(_ key: String, to property: inout String?) {
        if let value: String = self.property(key: key) {
            property = value
        }
    }
    
    /// Load Int property from env
    func load(_ key: String, to property: inout Int) {
        if let value = self.property(key: key), let converted = Int(value) {
            property = converted
        }
    }
    
    /// Load optional Int property from env
    func load(_ key: String, to property: inout Int?) {
        if let value = self.property(key: key), let converted = Int(value) {
            property = converted
        }
    }
    
    /// Load Bool property from env
    func load(_ key: String, to property: inout Bool) {
        if let value = self.property(key: key), let converted = value.bool {
            property = converted
        }
    }
    
    /// Load optional Bool property from env
    func load(_ key: String, to property: inout Bool?) {
        if let value = self.property(key: key), let converted = value.bool {
            property = converted
        }
    }
    
    /// Read property
    func property(key: String) -> String? {
        let value = (Environment.get(key) ?? Environment.get(key.uppercased()) ?? Environment.get(key.snake_cased()) ?? Environment.get(key.snake_cased().uppercased()))
        return value
    }
    
    /// Load configuration from a file. If a relative path is given, source root will be used as a starting point
    public static func load(fromFile path: String) throws -> Configuration {
        let url: URL
        if path.prefix(1) == "/" {
            url = URL(fileURLWithPath: path)
        } else {
            let config = DirectoryConfig.detect()
            url = URL(fileURLWithPath: config.workDir).appendingPathComponent(path)
        }
        let data = try Data(contentsOf: url)
        return try load(fromData: data)
    }
    
    /// Load configuration from a JSON string representation
    public static func load(fromString string: String) throws -> Configuration {
        guard let data = string.data(using: .utf8) else {
            throw Configuration.Error.invalidConfigurationData
        }
        return try load(fromData: data)
    }
    
    /// Load configuration from a Data string representation
    public static func load(fromData data: Data) throws -> Configuration {
        return try JSONDecoder().decode(Configuration.self, from: data)
    }
    
}
