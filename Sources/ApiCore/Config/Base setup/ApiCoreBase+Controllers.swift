//
//  ApiCoreBase+Controllers.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 17/04/2019.
//

import Foundation


extension ApiCoreBase {
    
    /// Boot routes for all registered controllers
    @discardableResult public static func boot(router: Router) throws -> (router: Router, secure: Router, debug: Router) {
        let group: Router
        if let prefix = configuration.server.pathPrefix {
            print("Using path prefix '\(prefix)' for all API endpoints")
            group = router.grouped(prefix)
        } else {
            group = router
        }
        
        let secureRouter = group.grouped(ApiAuthMiddleware.self)
        let debugRouter = group.grouped(DebugCheckMiddleware.self)
        
        for c in controllers {
            try c.boot(router: group, secure: secureRouter, debug: debugRouter)
        }
        
        return (group, secureRouter, debugRouter)
    }

}
