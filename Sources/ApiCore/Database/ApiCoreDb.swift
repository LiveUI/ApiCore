//
//  ApiCoreDb.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 20/09/2018.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL


class ApiCoreDb {
    
    /// Database configuration
    public static func config(hostname: String, user: String, password: String?, database: String, port: Int = DbDefaultPort) -> DatabasesConfig {
        var databaseConfig = DatabasesConfig()
        let config = PostgreSQLDatabaseConfig(hostname: hostname, port: port, username: user, database: database, password: password)
        let database = ApiCoreDatabase(config: config)
        databaseConfig.add(database: database, as: .db)
        
        // Enable SQL logging if required
        let env = ProcessInfo.processInfo.environment as [String: String]
        if env["DB_LOGGING"].asBool() {
            databaseConfig.enableLogging(on: .db)
        }
        
        return databaseConfig
    }
    
    /// Database configuration
    public static func envConfig(defaultHostname: String = "localhost", defaultUser: String = "root", defaultPassword: String? = nil, defaultDatabase: String, defaultPort: Int = 5432) -> DatabasesConfig {
        let env = ProcessInfo.processInfo.environment as [String: String]
        let host = env["DB_HOST"] ?? defaultHostname
        let port = Int(env["DB_PORT"] ?? "n/a") ?? defaultPort
        let user = env["DB_USER"] ?? defaultUser
        let pass = env["DB_PASSWORD"] ?? defaultPassword
        let dtbs = env["DB_NAME"] ?? defaultDatabase
        return config(hostname: host, user: user, password: pass, database: dtbs, port: port)
    }
    
}
