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
        public var singleTeam: Bool
        
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
            public var enabled: Bool
            
            /// Client / app ID
            public var client: String
            
            /// Client secret
            public var secret: String
            
            /// URL for github auth service (default is https://github.com)
            public var host: String
            
            /// URL for the github API (default is https://api.github.com)
            public var api: String
            
            /// Allowed teams
            public var teams: [String]
            
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
        
        /// Gitlab
        public struct Gitlab: Codable {
            
            /// Enable Github login
            public var enabled: Bool
            
            /// Client / app ID
            public var application: String
            
            /// Client secret
            public var secret: String
            
            /// URL for github auth service (default is https://gitlab.com)
            public var host: String
            
            /// URL for the github API (default is https://gitlab.com/api/v4/)
            public var api: String
            
            /// Allowed teams
            public var groups: [String]
            
            /// Initializer
            init(enabled: Bool, application: String, secret: String, host: String = "https://gitlab.com", api: String = "https://gitlab.com/api/v4/", groups: [String] = []) {
                self.enabled = enabled
                self.application = application
                self.secret = secret
                self.host = host
                self.api = api
                self.groups = groups
            }
            
        }
        
        /// Allow login using username and password
        public var allowLogin: Bool
        
        /// Allow new registrations (enabled by default)
        public var allowRegistrations: Bool
        
        /// Domains allowed to go through a self-registration process
        public var allowedDomainsForRegistration: [String]
        
        /// Allow new registrations (enabled by default)
        public var allowInvitations: Bool
        
        /// Domains allowed to go through a self-registration process
        public var allowedDomainsForInvitations: [String]
        
        /// Github login settings
        public var github: Github
        
        /// Gitlab login settings
        public var gitlab: Gitlab
        
        enum CodingKeys: String, CodingKey {
            case allowLogin = "allow_login"
            case allowRegistrations = "allow_registrations"
            case allowedDomainsForRegistration = "registration_domains"
            case allowInvitations = "allow_invitations"
            case allowedDomainsForInvitations = "invitation_domains"
            case github
            case gitlab
        }
        
        /// Initializer
        init(allowLogin: Bool, allowRegistrations: Bool, allowedDomainsForRegistration: [String], allowInvitations: Bool, allowedDomainsForInvitations: [String], github: Github, gitlab: Gitlab) {
            self.allowLogin = allowLogin
            self.allowRegistrations = allowRegistrations
            self.allowInvitations = allowInvitations
            self.allowedDomainsForRegistration = allowedDomainsForRegistration
            self.allowedDomainsForInvitations = allowedDomainsForInvitations
            self.github = github
            self.gitlab = gitlab
        }
        
    }
    
    /// Sertver info
    public final class Server: Codable {
        
        /// Server name
        public var name: String
        
        /// Server subtitle (motto, etc)
        public var subtitle: String?
        
        /// Server URL
        public var url: String?
        
        /// Server interface URL (optional)
        public var interface: String?
        
        ///
        public var pathPrefix: String?
        
        /// Max upload filesize (in Mb, default is 2Mb)
        public var maxUploadFilesize: Double?
        
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
        public var host: String?
        
        /// Database port, default 12324
        public var port: Int?
        
        /// Database user
        public var user: String
        
        /// Database password
        public var password: String?
        
        /// Database name
        public var database: String
        
        /// Enable query logging
        public var logging: Bool
        
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
        public var email: String = "admin@apicore"
        
        public var templates: String
        
        /// SMTP configuration string `smtp_server;username;password;port`
        public var smtp: String
        
        /// Mailgun configuration
        public final class MailGun: Codable {
            
            /// Mailgun domain
            public var domain: String
            
            /// Mailgun API key
            public var key: String
            
            /// Initializer
            init(domain: String, key: String) {
                self.domain = domain
                self.key = key
            }
            
        }
        
        /// Mailgun configuration
        public var mailgun: MailGun
        
        /// Initializer
        init(mailgun: MailGun, smtp: String, templates: String) {
            self.mailgun = mailgun
            self.smtp = smtp
            self.templates = templates
        }
        
    }
    
    /// Storage configuration
    public final class Storage: Codable {
        
        /// Local filesystem configuration
        public final class Local: Codable {
            
            /// Root storage folder path
            public var root: String
            
            /// Initializer
            init(root: String) {
                self.root = root
            }
            
        }
        
        /// S3 configuration
        public final class S3: Codable {
            
            /// Enable S3
            public var enabled: Bool
            
            /// Default bucket
            public var bucket: String
            
            /// AWS Access Key
            public var accessKey: String
            
            /// AWS Secret Key
            public var secretKey: String
            
            /// The region where S3 bucket is located.
            public var region: Region
            
            /// AWS Security Token. Used to validate temporary credentials, such as those from an EC2 Instance's IAM role
            public var securityToken : String?
            
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
        public var local: Local
        
        /// S3 configuration
        public var s3: S3
        
        /// Initializer
        init(local: Local, s3: S3) {
            self.local = local
            self.s3 = s3
        }
        
    }
    
    /// Templates configuration
    public final class Templates: Codable {
        
        /// Enable or disable templates endpoint
        public var enabled: Bool
        
        /// Root path
        public var root: String
        
        /// Initializer
        init(enabled: Bool, root: String) {
            self.enabled = enabled
            self.root = root
        }
        
    }
    
    /// General settings
    public var general: General
    
    /// Authentication settings
    public var auth: Auth
    
    /// Server info
    public var server: Server
    
    /// Word to use in JWT encoding / decoding
    public var jwtSecret: String
    
    /// Database information
    public var database: Database
    
    /// Email information
    public var mail: Mail
    
    /// Templates information
    public var templates: Templates
    
    /// Storage information
    public var storage: Storage
    
    enum CodingKeys: String, CodingKey {
        case general
        case auth
        case server
        case jwtSecret = "jwt_secret"
        case database
        case mail
        case templates
        case storage
    }
    
    /// Initialization
    public init(general: General, auth: Auth, server: Server, jwtSecret: String, database: Database, mail: Mail, templates: Templates, storage: Storage) {
        self.general = general
        self.auth = auth
        self.server = server
        self.jwtSecret = jwtSecret
        self.database = database
        self.mail = mail
        self.templates = templates
        self.storage = storage
    }
    
}


extension Configuration {
    
    /// Update from environmental variables
    public func loadEnv() {
        // Root
        load("APICORE_JWT_SECRET", to: &jwtSecret)
        
        // General
        load("APICORE_GENERAL_SINGLE_TEAM", to: &general.singleTeam)
        
        // Auth
        load("APICORE_AUTH_ALLOW_LOGIN", to: &auth.allowLogin)
        load("APICORE_AUTH_ALLOW_REGISTRATIONS", to: &auth.allowRegistrations)
        load("APICORE_AUTH_REGISTRATION_DOMAINS", to: &auth.allowedDomainsForRegistration)
        load("APICORE_AUTH_ALLOW_REGISTRATIONS", to: &auth.allowInvitations)
        load("APICORE_AUTH_INVITATION_DOMAINS", to: &auth.allowedDomainsForInvitations)
        
        load("APICORE_AUTH_GITHUB_ENABLED", to: &auth.github.enabled)
        load("APICORE_AUTH_GITHUB_CLIENT", to: &auth.github.client)
        load("APICORE_AUTH_GITHUB_SECRET", to: &auth.github.secret)
        load("APICORE_AUTH_GITHUB_HOST", to: &auth.github.host)
        load("APICORE_AUTH_GITHUB_API", to: &auth.github.api)
        load("APICORE_AUTH_GITHUB_TEAMS", to: &auth.github.teams)
        
        load("APICORE_AUTH_GITLAB_ENABLED", to: &auth.gitlab.enabled)
        load("APICORE_AUTH_GITLAB_APPLICATION", to: &auth.gitlab.application)
        load("APICORE_AUTH_GITLAB_SECRET", to: &auth.gitlab.secret)
        load("APICORE_AUTH_GITLAB_HOST", to: &auth.gitlab.host)
        load("APICORE_AUTH_GITLAB_API", to: &auth.gitlab.api)
        load("APICORE_AUTH_GITLAB_GROUPS", to: &auth.gitlab.groups)
        
        // Templates
        load("APICORE_TEMPLATES_ENABLED", to: &templates.enabled)
        load("APICORE_TEMPLATES_ROOT", to: &templates.root)
        
        // Mail
        load("APICORE_MAIL_EMAIL", to: &mail.email)
        
        load("APICORE_MAIL_SMTP", to: &mail.smtp)
        
        load("APICORE_MAIL_MAILGUN_DOMAIN", to: &mail.mailgun.domain)
        load("APICORE_MAIL_MAILGUN_KEY", to: &mail.mailgun.key)
        
        load("APICORE_MAIL_TEMPLATES", to: &mail.templates)
        
        // Database
        load("APICORE_DATABASE_HOST", to: &database.host)
        load("APICORE_DATABASE_USER", to: &database.user)
        load("APICORE_DATABASE_PASSWORD", to: &database.password)
        load("APICORE_DATABASE_PORT", to: &database.port)
        load("APICORE_DATABASE_DATABASE", to: &database.database)
        load("APICORE_DATABASE_LOGGING", to: &database.logging)

        // Server
        load("APICORE_SERVER_NAME", to: &server.name)
        load("APICORE_SERVER_SUBTITLE", to: &server.subtitle)
        load("APICORE_SERVER_URL", to: &server.url)
        load("APICORE_SERVER_INTERFACE", to: &server.interface)
        load("APICORE_SERVER_PATH_PREFIX", to: &server.pathPrefix)
        load("APICORE_SERVER_MAX_UPLOAD_FILESIZE", to: &server.maxUploadFilesize)

        // Storage (Local)
        load("APICORE_STORAGE_LOCAL_ROOT", to: &storage.local.root)
        
        // Storage (S3)
        load("APICORE_STORAGE_S3_ENABLED", to: &storage.s3.enabled)
        load("APICORE_STORAGE_S3_BUCKET", to: &storage.s3.bucket)
        load("APICORE_STORAGE_S3_ACCESS_KEY", to: &storage.s3.accessKey)
        load("APICORE_STORAGE_S3_SECRET_KEY", to: &storage.s3.secretKey)
        if let value = self.property(key: "APICORE_STORAGE_S3_REGION") {
            let name = Region.Name(value)
            let converted = Region(name: name)
            storage.s3.region = converted
        }
        load("APICORE_STORAGE_S3_SECURITY_TOKEN", to: &storage.s3.securityToken)
    }
    
}


extension Configuration {
    
    public static var `default`: Configuration {
        return Configuration(
            general: Configuration.General(
                singleTeam: false
            ),
            auth: Configuration.Auth(
                allowLogin: true,
                allowRegistrations: true,
                allowedDomainsForRegistration: [],
                allowInvitations: true,
                allowedDomainsForInvitations: [],
                github: Configuration.Auth.Github(
                    enabled: false,
                    client: "",
                    secret: ""
                ),
                gitlab: Configuration.Auth.Gitlab(
                    enabled: false,
                    application: "",
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
                ),
                smtp: "",
                templates: "https://raw.githubusercontent.com/Einstore/BaseEmailTemplates/master/templates.json"
            ),
            templates: Templates(
                enabled: true,
                root: "templates"
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
