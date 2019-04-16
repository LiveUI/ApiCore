//
//  RouteController.swift
//  Templator
//
//  Created by Ondrej Rafaj on 16/04/2019.
//

import Foundation
import Vapor
import Fluent


final class RouteController {
    
    static func boot<Database>(router: Router, database: Database.Type, permissionCheck: PermissionCheckClosure? = nil) throws where Database: SchemaSupporting & MigrationSupporting {
        let router = router.grouped("templates")
        
        func checkPermissions(_ route: Route, _ permissionCheck: PermissionCheckClosure?, _ execute: @escaping (() throws -> EventLoopFuture<Response>), on req: Request) throws -> EventLoopFuture<Response> {
            guard let permissionCheck = permissionCheck else {
                return try execute()
            }
            return try permissionCheck(route, req).flatMap(to: Response.self) { ok in
                guard ok else {
                    throw Templates<Database>.Error.unauthorized
                }
                return try execute()
            }
        }
        
        // List all templates
        router.get() { req -> EventLoopFuture<Response> in
            func execute() throws -> EventLoopFuture<Response> {
                return try TemplatorData<Database>.query(on: req).search(on: req).sort(\TemplatorData.name).all().map(to: Response.self) { data in
                    let response = try Response.encode(json: data, on: req)
                    return response
                }
            }
            return try checkPermissions(.list, permissionCheck, execute, on: req)
        }
        
        // Return a single template
        router.get(UUID.parameter) { req -> EventLoopFuture<Response> in
            func execute() throws -> EventLoopFuture<Response> {
                let id: UUID = try req.parameters.next()
                let result: EventLoopFuture<TemplatorData<Database>?> = try TemplatorManager.one(id: id, on: req)
                return result.map(to: Response.self) { data in
                    let response = try Response.encode(json: data, on: req)
                    return response
                }
            }
            return try checkPermissions(.get, permissionCheck, execute, on: req)
        }
        
        // Create a new template
        router.post() { req -> EventLoopFuture<Response> in
            func execute() throws -> EventLoopFuture<Response> {
                return try req.content.decode(TemplatorData<Database>.self).flatMap(to: Response.self) { template in
                    let checkFuture: EventLoopFuture<TemplatorData<Database>?> = try TemplatorManager.one(name: template.name, on: req)
                    return checkFuture.flatMap(to: Response.self) { check in
                        guard check == nil else {
                            throw Templates<Database>.Error.nameExists
                        }
                        template.id = nil
                        return template.save(on: req).map(to: Response.self) { template in
                            let response = try Response.encode(json: template, status: .created, on: req)
                            return response
                        }
                    }
                }
            }
            return try checkPermissions(.create, permissionCheck, execute, on: req)
        }
        
        // Update a template
        router.put(UUID.parameter) { req -> EventLoopFuture<Response> in
            func execute() throws -> EventLoopFuture<Response> {
                let id: UUID = try req.parameters.next()
                return try req.content.decode(TemplatorData<Database>.self).flatMap(to: Response.self) { template in
                    let checkFuture: EventLoopFuture<TemplatorData<Database>?> = try TemplatorManager.one(id: id, on: req)
                    return checkFuture.flatMap(to: Response.self) { check in
                        guard check?.id == id else {
                            throw Templates<Database>.Error.nameExists
                        }
                        template.id = id
                        return template.save(on: req).map(to: Response.self) { template in
                            let response = try Response.encode(json: template, status: .ok, on: req)
                            return response
                        }
                    }
                }
            }
            return try checkPermissions(.create, permissionCheck, execute, on: req)
        }
        
        // Delete a template
        router.delete(UUID.parameter) { req -> EventLoopFuture<Response> in
            func execute() throws -> EventLoopFuture<Response> {
                let id: UUID = try req.parameters.next()
                return try TemplatorManager.delete(id: id, database: database, on: req).map(to: Response.self) { _ in
                    return Response(http: HTTPResponse(status: .noContent), using: req)
                }
            }
            return try checkPermissions(.delete, permissionCheck, execute, on: req)
        }
    }
    
}
