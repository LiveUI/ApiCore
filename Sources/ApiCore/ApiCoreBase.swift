//
//  ApiCoreBase.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 09/12/2017.
//

import Foundation
import Vapor
import FluentPostgreSQL
import DbCore
import ErrorsCore
import MailCore
import Leaf
import FileCore


/// Main ApiCore class
public class ApiCoreBase {
    
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
                                maxUploadFilesize: nil
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
        DbCore.add(model: Token.self, database: .db)
        DbCore.add(model: Team.self, database: .db)
        DbCore.add(model: User.self, database: .db)
        DbCore.add(model: TeamUser.self, database: .db)
        DbCore.add(model: ErrorLog.self, database: .db)
        
        // Set database on tables that don't have migration
        FluentDesign.defaultDatabase = .db
        
        // Configuration
        // Load configuration
        let c = configuration
        
        // Database - Load database details
        let databaseConfig = DbCore.config(hostname: c.database.host ?? "localhost", user: c.database.user, password: c.database.password, database: c.database.database, port: c.database.port ?? 5432)
        
        // Setup mailing
        // TODO: Support SendGrid and SMTP!!!
        let mail = Mailer.Config.mailgun(key: c.mail.mailgun.key, domain: c.mail.mailgun.domain)
        try Mailer(config: mail, registerOn: &services)
        
        // Forward configure to the DbCore
        try DbCore.configure(databaseConfig: databaseConfig, &config, &env, &services)
        
        // Check JWT secret's security
        if env.isRelease && configuration.jwtSecret == "secret" {
            fatalError("You shouldn't be running around in a production mode with Configuration.jwt_secret set to \"secret\" as it is not very ... well, secret")
        }
        
        // System
        middlewareConfig.use(FileMiddleware.self)
        // TODO: CHANGE THE HARDCODED STUFF!!!!!!!!!!!
        services.register(FileMiddleware(publicDirectory: "/Projects/Web/Boost/Public/build/"))
        try services.register(LeafProvider())
        
        // Filesystem
        // TODO: Refactor following into converting helpers to cleanup this method!
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
        
        let jwtService = JWTService(secret: configuration.jwtSecret)
        services.register(jwtService)
        services.register(AuthenticationCache())
        
        // CORS
        let corsConfig = CORSMiddleware.Configuration(
            allowedOrigin: .originBased,
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
        middlewareConfig.use(CORSMiddleware(configuration: corsConfig))
        
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
