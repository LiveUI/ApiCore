//
//  ApiCoreBase.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 09/12/2017.
//

import Foundation
import Vapor
import FluentPostgreSQL
//import DbCore
import ErrorsCore
import MailCore
import Leaf
import FileCore


/// Default database typealias
public typealias ApiCoreDatabase = PostgreSQLDatabase

/// Default database connection type typealias
public typealias ApiCoreConnection = PostgreSQLConnection

/// Default database ID column type typealias
public typealias DbIdentifier = UUID

/// Default database port
public let DbDefaultPort: Int = 5432


/// Main ApiCore class
public class ApiCoreBase {
    
    /// Register models here
    public internal(set) static var models: [AnyModel.Type] = []
    
    /// Migration config
    public static var migrationConfig = MigrationConfig()
    
    /// Databse config
    public static var databaseConfig: DatabasesConfig?
    
    /// Add / register model
    public static func add<Model>(model: Model.Type, database: DatabaseIdentifier<Model.Database>) where Model: Fluent.Migration, Model: Fluent.Model, Model.Database: SchemaSupporting & QuerySupporting {
        models.append(model)
        migrationConfig.add(model: model, database: database)
    }
    
    /// Configuration cache
    static var _configuration: Configuration?
    
    /// Main system configuration
    public static var configuration: Configuration {
        get {
            if _configuration == nil {
                do {
                    guard let path = Environment.get("CONFIG_PATH") else {
                        let conf = try Configuration.load(fromFile: "config.default.json")
                        conf.loadEnv()
                        _configuration = conf
                        return conf
                    }
                    let conf = try Configuration.load(fromFile: path)
                    
                    // Override any properties with ENV
                    conf.loadEnv()
                    
                    _configuration = conf
                    return conf
                } catch {
                    if let error = error as? DecodingError {
                        // Should config exist but is invalid, crash
                        fatalError("Invalid configuration file: \(error.reason)")
                    } else {
                        // Create default configuration
                        _configuration = Configuration(
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
                        
                        // Override any properties with ENV
                        _configuration?.loadEnv()
                    }
                }
            }
            guard let configuration = _configuration else {
                fatalError("Configuration couldn't be loaded!")
            }
            return configuration
        }
    }
    
    /// Enable detailed request debugging
    public static var debugRequests: Bool = false
    
    public typealias DeleteTeamWarning = (_ team: Team) -> Future<Swift.Error?>
    public typealias DeleteUserWarning = (_ user: User) -> Future<Swift.Error?>
    
    /// Fire a warning before team get's deleted (to cascade in submodules, etc ...)
    public static var deleteTeamWarning: DeleteTeamWarning?
    
    /// Fire a warning before user get's deleted (to cascade in submodules, etc ...)
    public static var deleteUserWarning: DeleteUserWarning?
    
    /// Shared middleware config
    public internal(set) static var middlewareConfig = MiddlewareConfig()
    
    /// Add futures to be executed during an installation process
    public typealias InstallFutureClosure = (_ req: Request) throws -> Future<Void>
    public static var installFutures: [InstallFutureClosure] = []
    
    /// Registered Controllers with the API, these need to have a boot method to setup their routing
    static var controllers: [Controller.Type] = [
        GenericController.self,
        InstallController.self,
        AuthController.self,
        UsersController.self,
        TeamsController.self,
        LogsController.self,
        ServerController.self
    ]
    
    /// Main configure method for ApiCore
    public static func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
        // Set max upload filesize
        let mb = Double(configuration.server.maxUploadFilesize ?? 50)
        let maxBodySize = Int(Filesize.megabyte(mb).value)
        let serverConfig = NIOServerConfig.default(maxBodySize: maxBodySize)
        services.register(serverConfig)
        
        // Migrate models / tables
        add(model: Token.self, database: .db)
        add(model: Team.self, database: .db)
        add(model: User.self, database: .db)
        add(model: TeamUser.self, database: .db)
        add(model: ErrorLog.self, database: .db)
        
        // Set database on tables that don't have migration
        FluentDesign.defaultDatabase = .db
        
        // Configuration
        // Load configuration
        let c = configuration
        
        // Database - Load database details
        let databaseConfig = ApiCoreDb.config(hostname: c.database.host ?? "localhost", user: c.database.user, password: c.database.password, database: c.database.database, port: c.database.port ?? 5432)
        
        // Setup mailing
        // TODO: MVP! Support SendGrid and SMTP!!!!!!
        let mail = Mailer.Config.mailgun(key: c.mail.mailgun.key, domain: c.mail.mailgun.domain)
        try Mailer(config: mail, registerOn: &services)
        
        // Configure database
        try services.register(FluentPostgreSQLProvider())
        
        self.databaseConfig = databaseConfig
        
        services.register(databaseConfig)
        services.register(migrationConfig)
        
        // Check JWT secret's security
        if env.isRelease && configuration.jwtSecret == "secret" {
            fatalError("You shouldn't be running around in a production mode with Configuration.jwt_secret set to \"secret\" as it is not very ... well, secret")
        }
        
        // CORS
        let corsConfig = CORSMiddleware.Configuration(
            allowedOrigin: .all,
            allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
            allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent],
            exposedHeaders: [
                HTTPHeaderName.authorization.description,
                HTTPHeaderName.contentLength.description,
                HTTPHeaderName.contentType.description,
                HTTPHeaderName.contentDisposition.description,
                HTTPHeaderName.cacheControl.description,
                HTTPHeaderName.expires.description
            ]
        )
        let cors = CORSMiddleware(configuration: corsConfig)
        middlewareConfig.use(cors)
        
        // Templates
        try services.register(LeafProvider())
        
        // Filesystem
        // TODO: Refactor following to cleanup this method!
        if configuration.storage.s3.enabled {
            let config = S3Signer.Config(accessKey: configuration.storage.s3.accessKey,
                                         secretKey: configuration.storage.s3.secretKey,
                                         region: configuration.storage.s3.region,
                                         securityToken: configuration.storage.s3.securityToken
            )
            try services.register(s3: config, defaultBucket: configuration.storage.s3.bucket)
            try services.register(fileCoreManager: .s3(
                config,
                configuration.storage.s3.bucket
            ))
        } else {
            try services.register(fileCoreManager: .local(LocalConfig(root: configuration.storage.local.root)))
        }
        
        // UUID service
        services.register(RequestIdService.self)
        
        // Errors
        middlewareConfig.use(ErrorLoggingMiddleware.self)
        services.register(ErrorLoggingMiddleware())
        
        middlewareConfig.use(ErrorsCoreMiddleware.self)
        services.register(ErrorsCoreMiddleware(environment: env, log: PrintLogger()))
        
        // Authentication
        middlewareConfig.use(ApiAuthMiddleware.self)
        services.register(ApiAuthMiddleware())
        
        services.register { _ in
            JWTService(secret: configuration.jwtSecret)
        }
        services.register(AuthenticationCache.self)
        
        // Register middlewares
        services.register(middlewareConfig)
        
        // Install default templates
        Templates.installMissing()
    }
    
    /// Boot routes for all registered controllers
    public static func boot(router: Router) throws {
        for c in controllers {
            try c.boot(router: router)
        }
    }
    
}
