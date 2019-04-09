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
        
        /// Github
        public struct Github: Codable {
            
            /// Enable Github login
            public internal(set) var enabled: Bool
            
            /// Client / app ID
            public internal(set) var client: String
            
            /// Client secret
            public internal(set) var secret: String
            
            /// URL for github auth service (default is https://github.com)
            public internal(set) var host: String
            
            /// URL for the github API (default is https://api.github.com)
            public internal(set) var api: String
            
            /// Allowed teams
            public internal(set) var teams: [String]
            
            /// Initializer
            init(enabled: Bool, client: String, secret: String, host: String = "https://github.com", api: String = "https://api.github.com", teams: [String] = []) {
                self.enabled = enabled
                self.client = client
                self.secret = secret
                self.host = host
                self.api = api
                self.teams = teams
            }
            
        }
        
        /// Allow new registrations (enabled by default)
        public internal(set) var allowRegistrations: Bool
        
        /// Domains allowed to go through a self-registration process
        public internal(set) var allowedDomainsForRegistration: [String]
        
        /// Allow new registrations (enabled by default)
        public internal(set) var allowInvitations: Bool
        
        /// Domains allowed to go through a self-registration process
        public internal(set) var allowedDomainsForInvitations: [String]
        
        /// Github login settings
        public internal(set) var github: Github
        
        enum CodingKeys: String, CodingKey {
            case allowRegistrations = "allow_registrations"
            case allowedDomainsForRegistration = "registration_domains"
            case allowInvitations = "allow_invitations"
            case allowedDomainsForInvitations = "invitation_domains"
            case github
        }
        
        /// Initializer
        init(allowRegistrations: Bool, allowedDomainsForRegistration: [String], allowInvitations: Bool, allowedDomainsForInvitations: [String], github: Github) {
            self.allowRegistrations = allowRegistrations
            self.allowInvitations = allowInvitations
            self.allowedDomainsForRegistration = allowedDomainsForRegistration
            self.allowedDomainsForInvitations = allowedDomainsForInvitations
            self.github = github
        }
        
    }
    
    /// Sertver info
    public final class Server: Codable {
        
        /// Server name
        public internal(set) var name: String
        
        /// Server subtitle (motto, etc)
        public internal(set) var subtitle: String?
        
        /// Server URL
        public internal(set) var url: String?
        
        /// Server interface URL (optional)
        public internal(set) var interface: String?
        
        ///
        public internal(set) var pathPrefix: String?
        
        /// Max upload filesize (in Mb, default is 2Mb)
        public internal(set) var maxUploadFilesize: Double?
        
        enum CodingKeys: String, CodingKey {
            case name
            case subtitle
            case url
            case maxUploadFilesize = "max_upload"
            case pathPrefix = "path_prefix"
        }
        
        /// Initializer
        init(name: String, subtitle: String? = nil, url: String?, maxUploadFilesize: Double?) {
            self.name = name
            self.subtitle = subtitle
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
        load("apicore_jwt_secret", to: &jwtSecret)
        
        // General
        load("apicore_general.single_team", to: &general.singleTeam)
        
        // Auth
        load("apicore_auth_allow_registrations", to: &auth.allowRegistrations)
        load("apicore_auth_registration_domains", to: &auth.allowedDomainsForRegistration)
        load("apicore_auth_allow_registrations", to: &auth.allowInvitations)
        load("apicore_auth_invitation_domains", to: &auth.allowedDomainsForInvitations)
        
        load("apicore_auth_github_enabled", to: &auth.github.enabled)
        load("apicore_auth_github_client", to: &auth.github.client)
        load("apicore_auth_github_secret", to: &auth.github.secret)
        load("apicore_auth_github_host", to: &auth.github.host)
        load("apicore_auth_github_api", to: &auth.github.api)
        load("apicore_auth_github_teams", to: &auth.github.teams)
        
        // Mail
        load("apicore_mail.email", to: &mail.email)
        
        load("apicore_mail.mailgun.domain", to: &mail.mailgun.domain)
        load("apicore_mail.mailgun.key", to: &mail.mailgun.key)

        // Database
        load("apicore_database.host", to: &database.host)
        load("apicore_database.user", to: &database.user)
        load("apicore_database.password", to: &database.password)
        load("apicore_database.port", to: &database.port)
        load("apicore_database.database", to: &database.database)
        load("apicore_database.logging", to: &database.logging)

        // Server
        load("apicore_server.name", to: &server.name)
        load("apicore_server.subtitle", to: &server.subtitle)
        load("apicore_server.url", to: &server.url)
        load("apicore_server.interface", to: &server.interface)
        load("apicore_server.path_prefix", to: &server.pathPrefix)
        load("apicore_server.max_upload_filesize", to: &server.maxUploadFilesize)

        // Storage (Local)
        load("apicore_storage.local.root", to: &storage.local.root)

        // Storage (S3)
        load("apicore_storage.s3.enabled", to: &storage.s3.enabled)
        load("apicore_storage.s3.bucket", to: &storage.s3.bucket)
        load("apicore_storage.s3.access_key", to: &storage.s3.accessKey)
        load("apicore_storage.s3.secret_key", to: &storage.s3.secretKey)
        if let value = self.property(key: "apicore_storage.s3.region") {
            let name = Region.Name(value)
            let converted = Region(name: name)
            storage.s3.region = converted
        }
        load("apicore_storage.s3.security_token", to: &storage.s3.securityToken)
    }
    
}


extension Configuration {
    
    public static var `default`: Configuration {
        return Configuration(
            general: Configuration.General(
                singleTeam: false
            ),
            auth: Configuration.Auth(
                allowRegistrations: true,
                allowedDomainsForRegistration: [],
                allowInvitations: true,
                allowedDomainsForInvitations: [],
                github: Configuration.Auth.Github(
                    enabled: false,
                    client: "",
                    secret: ""
                )
            ),
            server: Configuration.Server(
                name: "API Core!",
                url: nil,
                maxUploadFilesize: 2 // 2Mb
            ),
            jwtSecret: "secret",
            database: Configuration.Database(
                host: nil,
                port: nil,
                user: "apicore",
                password: "aaaaaa",
                database: "apicore",
                logging: false
            ),
            mail: Configuration.Mail(
                mailgun: Configuration.Mail.MailGun(
                    domain: "",
                    key: ""
                )
            ),
            storage: Configuration.Storage(
                local: Configuration.Storage.Local(root: "/tmp/Boost"),
                s3: Configuration.Storage.S3(
                    enabled: false,
                    bucket: "",
                    accessKey: "",
                    secretKey: "",
                    region: .apSoutheast1,
                    securityToken: nil
                )
            )
        )
    }
    
}
