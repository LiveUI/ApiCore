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
        databaseConfig.add(database: database, as: .psql)
        
        // Enable SQL logging if required
        if ApiCoreBase.configuration.database.logging {
            databaseConfig.enableLogging(on: .psql)
        }
        
        return databaseConfig
    }
    
}

