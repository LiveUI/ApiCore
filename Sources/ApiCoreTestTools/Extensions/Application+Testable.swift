//
//  Application+Testable.swift
//  ApiCoreTestTools
//
//  Created by Ondrej Rafaj on 27/02/2018.
//

import Foundation
@testable import ApiCore
import Vapor
import Fluent
import VaporTestTools
import MailCore
import MailCoreTestTools


public struct Paths {
    
    public var rootUrl: URL {
        let config = DirectoryConfig.detect()
        let url = URL(fileURLWithPath: config.workDir)
        return url
    }
    
    public var resourcesUrl: URL {
        let url = rootUrl.appendingPathComponent("Resources")
        return url
    }
    
    public var publicUrl: URL {
        let url = rootUrl.appendingPathComponent("Public")
        return url
    }
    
}


extension TestableProperty where TestableType: Application {
    
    public static var paths: Paths {
        return Paths()
    }
    
    public static func newApiCoreTestApp(databaseConfig: DatabasesConfig? = nil, _ configClosure: AppConfigClosure? = nil, _ routerClosure: AppRouterClosure? = nil) -> Application {
        let app = new({ (config, env, services) in
            // Reset static configs
            ApiCoreBase.migrationConfig = MigrationConfig()
            ApiCoreBase.middlewareConfig = MiddlewareConfig()
            
            try! ApiCoreBase.configure(&config, &env, &services)
            
            #if os(macOS)
            // Check the database ... if it doesn't contain test then make sure we are not pointing to a production DB
            if !ApiCoreBase.configuration.database.database.contains("-test") {
                ApiCoreBase.configuration.database.database = ApiCoreBase.configuration.database.database + "-test"
            }
            #endif
            
            // Set mailer mock
            MailerMock(services: &services)
            config.prefer(MailerMock.self, for: MailerService.self)
            
            configClosure?(&config, &env, &services)
        }) { (router) in
            routerClosure?(router)
            try! ApiCoreBase.boot(router: router)
        }
        
        return app
    }
    
}
