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
        let name: String
        
        /// Server URL
        let url: String?
        
        /// Max upload filesize (in Mb, default is 50)
        let maxUploadFilesize: Int?
        
        enum CodingKeys: String, CodingKey {
            case name
            case url
            case maxUploadFilesize = "max_upload"
        }
        
    }
    
    /// Database info
    public struct Database: Codable {
        
        /// Database host
        let host: String
        
        /// Database port
        let port: Int
        
        /// Database user
        let user: String
        
        /// Database password
        let password: String
        
        /// Database name
        let database: String
        
        /// Enable query logging
        let logging: Bool
        
    }
    
    /// Email configuration
    public struct Mail: Codable {
        
        /// Mailgun configuration
        public struct MailGun: Codable {
            let domain: String
            let key: String
        }
        
        /// Mailgun configuration
        let mailgun: MailGun
        
    }
    
    /// Server info
    let server: Server
    
    /// Word to use in JWT encoding / decoding
    let jwtSecret: String
    
    /// Database information
    let database: Database
    
    /// Email information
    let mail: Mail
    
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
