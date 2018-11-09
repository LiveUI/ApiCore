//
//  Configuration.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 23/04/2018.
//

import Foundation
import Vapor
import S3Signer


/// Configuration object
public final class Configuration: Configurable {
    
    /// Config Error
    public enum Error: Swift.Error {
        case invalidConfigurationData
    }
    
    /// General
    public final class General: Codable {
        
        /// Single team server (all team functionality will be disabled, all new users will be automatically assigned to the main team if enabled)
        /// (disabled by default)
        public internal(set) var singleTeam: Bool
        
        enum CodingKeys: String, CodingKey {
            case singleTeam = "single_team"
        }
        
        /// Initializer
        init(singleTeam: Bool) {
            self.singleTeam = singleTeam
        }
        
    }
    
    /// Authentication
    public final class Auth: Codable {
        
        /// Allow new registrations (enabled by default)
        public internal(set) var allowRegistrations: Bool
        
        /// Allow new registrations (enabled by default)
        public internal(set) var allowInvitations: Bool
        
        /// Domains allowed to go through a self-registration process
        public internal(set) var allowedDomainsForRegistration: [String]
        
        enum CodingKeys: String, CodingKey {
            case allowRegistrations = "allow_registrations"
            case allowInvitations = "allow_invitations"
            case allowedDomainsForRegistration = "registration_domains"
        }
        
        /// Initializer
        init(allowRegistrations: Bool, allowInvitations: Bool, allowedDomainsForRegistration: [String]) {
            self.allowRegistrations = allowRegistrations
            self.allowInvitations = allowInvitations
            self.allowedDomainsForRegistration = allowedDomainsForRegistration
        }
        
    }
    
    /// Sertver info
    public final class Server: Codable {
        
        /// Server name
        public internal(set) var name: String
        
        /// Server URL
        public internal(set) var url: String?

        ///
        public internal(set) var pathPrefix: String?
        
        /// Max upload filesize (in Mb, default is 2Mb)
        public internal(set) var maxUploadFilesize: Double?
        
        enum CodingKeys: String, CodingKey {
            case name
            case url
            case maxUploadFilesize = "max_upload"
            case pathPrefix = "path_prefix"
        }
        
        /// Initializer
        init(name: String, url: String?, maxUploadFilesize: Double?) {
            self.name = name
            self.url = url
            self.maxUploadFilesize = maxUploadFilesize
        }
        
    }
    
    /// Database info
    public final class Database: Codable {
        
        /// Database host, default `localhost`
        public internal(set) var host: String?
        
        /// Database port, default 12324
        public internal(set) var port: Int?
        
        /// Database user
        public internal(set) var user: String
        
        /// Database password
        public internal(set) var password: String?
        
        /// Database name
        public internal(set) var database: String
        
        /// Enable query logging
        public internal(set) var logging: Bool
        
        /// Initializer
        init(host: String?, port: Int?, user: String, password: String?, database: String, logging: Bool) {
            self.host = host
            self.port = port
            self.user = user
            self.password = password
            self.database = database
            self.logging = logging
        }
        
    }
    
    /// Email configuration
    public final class Mail: Codable {
        
        /// Admin email (all administration emails should be sent from this email)
        public internal(set) var email: String = "admin@apicore"
        
        /// Mailgun configuration
        public final class MailGun: Codable {
            
            /// Mailgun domain
            public internal(set) var domain: String
            
            /// Mailgun API key
            public internal(set) var key: String
            
            /// Initializer
            init(domain: String, key: String) {
                self.domain = domain
                self.key = key
            }
            
        }
        
        /// Mailgun configuration
        public internal(set) var mailgun: MailGun
        
        /// Initializer
        init(mailgun: MailGun) {
            self.mailgun = mailgun
        }
        
    }
    
    /// Storage configuration
    public final class Storage: Codable {
        
        /// Local filesystem configuration
        public final class Local: Codable {
            
            /// Root storage folder path
            public internal(set) var root: String
            
            /// Initializer
            init(root: String) {
                self.root = root
            }
            
        }
        
        /// S3 configuration
        public final class S3: Codable {
            
            /// Enable S3
            public internal(set) var enabled: Bool
            
            /// Default bucket
            public internal(set) var bucket: String
            
            /// AWS Access Key
            public internal(set) var accessKey: String
            
            /// AWS Secret Key
            public internal(set) var secretKey: String
            
            /// The region where S3 bucket is located.
            public internal(set) var region: Region
            
            /// AWS Security Token. Used to validate temporary credentials, such as those from an EC2 Instance's IAM role
            public internal(set) var securityToken : String?
            
            /// Initializer
            init(enabled: Bool, bucket: String, accessKey: String, secretKey: String, region: Region, securityToken: String?) {
                self.enabled = enabled
                self.bucket = bucket
                self.accessKey = accessKey
                self.secretKey = secretKey
                self.region = region
                self.securityToken = securityToken
            }
            
            enum CodingKeys: String, CodingKey {
                case enabled
                case bucket
                case accessKey = "access_key"
                case secretKey = "secret_key"
                case region
                case securityToken = "security_token"
            }
            
        }
        
        /// Local filestorage configuration
        public internal(set) var local: Local
        
        /// S3 configuration
        public internal(set) var s3: S3
        
        /// Initializer
        init(local: Local, s3: S3) {
            self.local = local
            self.s3 = s3
        }
        
    }
    
    /// General settings
    public internal(set) var general: General
    
    /// Authentication settings
    public internal(set) var auth: Auth
    
    /// Server info
    public internal(set) var server: Server
    
    /// Word to use in JWT encoding / decoding
    public internal(set) var jwtSecret: String
    
    /// Database information
    public internal(set) var database: Database
    
    /// Email information
    public internal(set) var mail: Mail
    
    /// Storage information
    public internal(set) var storage: Storage
    
    enum CodingKeys: String, CodingKey {
        case general
        case auth
        case server
        case jwtSecret = "jwt_secret"
        case database
        case mail
        case storage
    }
    
    /// Initialization
    public init(general: General, auth: Auth, server: Server, jwtSecret: String, database: Database, mail: Mail, storage: Storage) {
        self.general = general
        self.auth = auth
        self.server = server
        self.jwtSecret = jwtSecret
        self.database = database
        self.mail = mail
        self.storage = storage
    }
    
}


extension Configuration {
    
    /// Update from environmental variables
    public func loadEnv() {
        // Root
        load("apicore.jwt_secret", to: &jwtSecret)
        
        // General
        load("apicore.general.single_team", to: &general.singleTeam)
        
        // Auth
        load("apicore.auth.allow_registrations", to: &auth.allowRegistrations)
        load("apicore.auth.allow_invitations", to: &auth.allowInvitations)
        
        // Mail
        load("apicore.mail.email", to: &mail.email)
        
        load("apicore.mail.mailgun.domain", to: &mail.mailgun.domain)
        load("apicore.mail.mailgun.domain", to: &mail.mailgun.domain)
        load("apicore.mail.mailgun.key", to: &mail.mailgun.key)

        // Database
        load("apicore.database.host", to: &database.host)
        load("apicore.database.user", to: &database.user)
        load("apicore.database.password", to: &database.password)
        load("apicore.database.port", to: &database.port)
        load("apicore.database.database", to: &database.database)
        load("apicore.database.logging", to: &database.logging)

        // Server
        load("apicore.server.name", to: &server.name)
        load("apicore.server.url", to: &server.url)
        load("apicore.server.path_prefix", to: &server.pathPrefix)
        load("apicore.server.max_upload_filesize", to: &server.maxUploadFilesize)

        // Storage (Local)
        load("apicore.storage.local.root", to: &storage.local.root)

        // Storage (S3)
        load("apicore.storage.s3.enabled", to: &storage.s3.enabled)
        load("apicore.storage.s3.bucket", to: &storage.s3.bucket)
        load("apicore.storage.s3.access_key", to: &storage.s3.accessKey)
        load("apicore.storage.s3.secret_key", to: &storage.s3.secretKey)
        if let value = self.property(key: "apicore.storage.s3.region"), let converted = Region(rawValue: value) {
            storage.s3.region = converted
        }
        load("apicore.storage.s3.security_token", to: &storage.s3.securityToken)
    }
    
}
