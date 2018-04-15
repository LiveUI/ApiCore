//
//  InstallController.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 13/01/2018.
//

import Foundation
import Vapor
import ErrorsCore
import DbCore


public class InstallController: Controller {
    
    public enum InstallError: FrontendError {
        case dataExists
        
        public var code: String {
            return "install_failed"
        }
        
        public var description: String {
            return "Data already exists"
        }
        
        public var status: HTTPStatus {
            return .preconditionFailed
        }
    }
    
    public static func boot(router: Router) throws {
        router.get("install") { (req)->Future<Response> in
            return install(on: req)
        }
        
        router.get("tables") { req in
            // TODO: Show table names and other info
            return FluentDesign.query(on: req).all()
        }
    }
    
}


extension InstallController {
    
    private static var su: User {
        return User(username: "admin", firstname: "Super", lastname: "Admin", email: "admin@liveui.io", password: "admin", disabled: false, su: true)
    }
    
    private static var adminTeam: Team {
        return Team(name: "Admin team", identifier: "admin-team", admin: true)
    }
    
    private static func install(on req: Request) -> Future<Response> {
        return User.query(on: req).count().flatMap(to: Response.self) { count in
            if count > 0 {
                throw InstallError.dataExists
            }
            return su.save(on: req).flatMap(to: Response.self) { user in
                return adminTeam.save(on: req).flatMap(to: Response.self) { team in
                    var futures = [
                        team.users.attach(user, on: req).flatten()
                    ]
                    try ApiCore.installFutures.forEach({ closure in
                        futures.append(try closure(req))
                    })
                    return futures.map(to: Response.self, on: req) { join in
                        return try req.response.maintenanceFinished(message: "Installation finished, login as admin@liveui.io/admin")
                    }
                }
            }
        }
    }
    
}
