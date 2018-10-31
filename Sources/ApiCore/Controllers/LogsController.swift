//
//  LogsController.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 11/03/2018.
//

import Foundation
import Vapor
import FluentPostgreSQL

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif


public class LogsController: Controller {
    
    /// Setup routes
    public static func boot(router: Router, secure: Router, debug: Router) throws {
        // Print out logged errors
        secure.get("errors") { req -> Future<[ErrorLog]> in
            return ErrorLog.query(on: req).sort(\ErrorLog.added, .descending).all()
        }
        
        // Flush system logs
        debug.get("flush") { req -> Response in
            fflush(stdout)
            return try req.response.success(status: .ok, code: "system", description: "Flushed")
        }
    }
    
}
