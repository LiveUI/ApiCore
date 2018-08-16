//
//  GenericController.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 13/01/2018.
//

import Foundation
import Vapor


/// Generic/default routes
public class GenericController: Controller {
    
    /// Setup routes
    public static func boot(router: Router) throws {
        // Any uknown GET URL
        router.get(PathComponent.anything) { req in
            return try req.response.badUrl()
        }
        
        // Any uknown POST URL
        router.post(PathComponent.anything) { req in
            return try req.response.badUrl()
        }
        
        // Any uknown PUT URL
        router.put(PathComponent.anything) { req in
            return try req.response.badUrl()
        }
        
        // Any uknown PATCH URL
        router.patch(PathComponent.anything) { req in
            return try req.response.badUrl()
        }
        
        // Any uknown DELETE URL
        router.delete(PathComponent.anything) { req in
            return try req.response.badUrl()
        }
        
        // I am a teapot, really!
        router.get("teapot") { req in
            return try req.response.teapot()
        }
        
        // Ping response (ok, 200)
        router.get("ping") { req in
            return try req.response.ping()
        }
        
    }
    
}
