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
import Fluent


public class InstallController: Controller {
    
    public enum InstallError: FrontendError {
        case dataExists
        
        public var identifier: String {
            return "install_failed.data_exists"
        }
        
        public var reason: String {
            return "Data already exists"
        }
        
        public var status: HTTPStatus {
            return .preconditionFailed
        }
    }
    
    public static func boot(router: Router) throws {
        router.get("install") { (req)->Future<Response> in
            return try install(on: req)
        }
        
        router.get("uninstall") { (req)->Future<Response> in
            return try uninstall(on: req)
        }
        
        router.get("reinstall") { (req)->Future<Response> in
            return try uninstall(on: req).flatMap(to: Response.self) { _ in
                return try install(on: req).map(to: Response.self) { _ in
                    return try req.response.maintenanceFinished(message: "Re-installation finished, login as admin@liveui.io/admin")
                }
            }
        }
        
        router.get("database") { req in
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
    
    private static func uninstall(on req: Request) throws -> Future<Response> {
        var futures: [Future<Void>] = []
        return req.requestPooledConnection(to: .db).flatMap(to: Response.self) { connection in
            for model in DbCore.models {
                futures.append(connection.query("DROP TABLE IF EXISTS \(model.entity)").flatten())
            }
            return futures.flatten(on: req).flatMap(to: Void.self) { _ in
                return FluentDesign.query(on: req).delete()
            }.map(to: Response.self) { _ in
                return try req.response.maintenanceFinished(message: "Uninstall finished, there are no data nor tables in the database; Please run `/install` before you continue")
            }
        }
    }
    
    private static func install(on req: Request) throws -> Future<Response> {
        let migrations = FluentProvider.init()
        return try migrations.didBoot(req).flatMap(to: Response.self) { _ in
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
                        return futures.map(to: Response.self, on: req) { _ in
                            return try req.response.maintenanceFinished(message: "Installation finished, login as admin@liveui.io/admin")
                        }
                    }
                }
            }
        }
    }
    
}
