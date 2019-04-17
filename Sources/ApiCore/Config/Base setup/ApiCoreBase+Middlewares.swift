//
//  ApiCoreBase+Middlewares.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 17/04/2019.
//

import Foundation
import Vapor
import ErrorsCore


extension ApiCoreBase {
    
    static func setupMiddlewares(_ services: inout Services, _ env: inout Environment, _ config: inout Config) throws {
        // Errors
        middlewareConfig.use(ErrorLoggingMiddleware.self)
        services.register(ErrorLoggingMiddleware())
        
        middlewareConfig.use(ErrorsCoreMiddleware.self)
        services.register(ErrorsCoreMiddleware(environment: env, log: PrintLogger()))
        
        // Authentication
        services.register(ApiAuthMiddleware())
        services.register(DebugCheckMiddleware())
        
        // Debugging
        if !env.isRelease {
            middlewareConfig.use(UrlPrinterMiddleware.self)
            services.register(UrlPrinterMiddleware())
        }
        
        services.register { _ in
            JWTService(secret: configuration.jwtSecret)
        }
        services.register(AuthenticationCache.self)
        
        // Sessions middleware
        config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
        middlewareConfig.use(SessionsMiddleware.self)
        
        // Register middlewares
        services.register(middlewareConfig)
    }
    
}
