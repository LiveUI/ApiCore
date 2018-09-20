//
//  InstallController.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 13/01/2018.
//

import Foundation
import Vapor
import ErrorsCore
//import DbCore
import Fluent
import FluentPostgreSQL


public class InstallController: Controller {
    
    /// Error
    public enum Error: FrontendError {
        
        /// Data exists
        case dataExists
        
        /// Error code
        public var identifier: String {
            return "install_failed.data_exists"
        }
        
        /// Reason to fail
        public var reason: String {
            return "Data already exists"
        }
        
        /// Error HTTP code
        public var status: HTTPStatus {
            return .preconditionFailed
        }
    }
    
    /// Setup routes
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
                    return try req.response.maintenanceFinished(message: "Re-installation finished, login as core@liveui.io/admin")
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
    
    /// New super user
    private static func su(on req: Request) throws -> User {
        return try User(username: "admin", firstname: "Super", lastname: "Admin", email: "core@liveui.io", password: "admin".passwordHash(req), disabled: false, su: true)
    }
    
    /// New admin team
    private static var adminTeam: Team {
        return Team(name: "Admin team", identifier: "admin-team", admin: true)
    }
    
    /// Uninstall all data and drop all tables
    private static func uninstall(on req: Request) throws -> Future<Response> {
        var futures: [Future<Void>] = []
        return req.requestPooledConnection(to: .db).flatMap(to: Response.self) { connection in
            for model in ApiCoreBase.models {
                futures.append(connection.query(PostgreSQLQuery.raw("DROP TABLE IF EXISTS \(model.entity)", binds: [])).flatten())
            }
            return futures.flatten(on: req).flatMap(to: Void.self) { _ in
                return FluentDesign.query(on: req).delete()
            }.map(to: Response.self) { _ in
                return try req.response.maintenanceFinished(message: "Uninstall finished, there are no data nor tables in the database; Please run `/install` before you continue")
            }
        }
    }
    
    /// Install all tables and data if neccessary
    private static func install(on req: Request) throws -> Future<Response> {
        return try install(files: req).flatMap({
            return try install(migrations: req).map({
                return try req.response.maintenanceFinished(message: "Installation finished, login as core@liveui.io/admin")
            })
        })
    }
    
    /// Install base files
    private static func install(files req: Request) throws -> Future<Void> {
        return try Logo.install(on: req)
    }
    
    /// Install basic database data
    private static func install(migrations req: Request) throws -> Future<Void> {
        let migrations = FluentProvider.init()
        return try migrations.didBoot(req).flatMap(to: Void.self) { _ in
            return User.query(on: req).count().flatMap(to: Void.self) { count in
                if count > 0 {
                    throw Error.dataExists
                }
                let user = try su(on: req)
                user.verified = true
                return user.save(on: req).flatMap(to: Void.self) { user in
                    return adminTeam.save(on: req).flatMap(to: Void.self) { team in
                        var futures = [
                            team.users.attach(user, on: req).flatten()
                        ]
                        try ApiCoreBase.installFutures.forEach({ closure in
                            futures.append(try closure(req))
                        })
                        return futures.flatten(on: req)
                    }
                }
            }
        }
    }
    
}
