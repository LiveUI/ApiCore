//
//  Configuration.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 23/04/2018.
//

import Foundation
import Vapor


/// Configuration object
public struct Configuration: Codable {
    
    /// Config Error
    public enum Error: Swift.Error {
        case invalidConfigurationData
    }
    
    /// Sertver info
    public struct Server: Codable {
        
        /// Server name
        public internal(set) var name: String
        
        /// Server URL
        public internal(set) var url: String?
        
        /// Max upload filesize (in Mb, default is 50)
        public internal(set) var maxUploadFilesize: Int?
        
        enum CodingKeys: String, CodingKey {
            case name
            case url
            case maxUploadFilesize = "max_upload"
        }
        
    }
    
    /// Database info
    public struct Database: Codable {
        
        /// Database host
        public internal(set) var host: String
        
        /// Database port
        public internal(set) var port: Int
        
        /// Database user
        public internal(set) var user: String
        
        /// Database password
        public internal(set) var password: String
        
        /// Database name
        public internal(set) var database: String
        
        /// Enable query logging
        public internal(set) var logging: Bool
        
    }
    
    /// Email configuration
    public struct Mail: Codable {
        
        /// Mailgun configuration
        public struct MailGun: Codable {
            let domain: String
            let key: String
        }
        
        /// Mailgun configuration
        public internal(set) var mailgun: MailGun
        
    }
    
    /// Server info
    public internal(set) var server: Server
    
    /// Word to use in JWT encoding / decoding
    public internal(set) var jwtSecret: String
    
    /// Database information
    public internal(set) var database: Database
    
    /// Email information
    public internal(set) var mail: Mail
    
    enum CodingKeys: String, CodingKey {
        case server
        case jwtSecret = "jwt_secret"
        case database
        case mail
    }
    
}


extension Configuration {
    
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
            throw Error.invalidConfigurationData
        }
        return try load(fromData: data)
    }
    
    /// Load configuration from a Data string representation
    public static func load(fromData data: Data) throws -> Configuration {
        return try JSONDecoder().decode(Configuration.self, from: data)
    }
    
}
