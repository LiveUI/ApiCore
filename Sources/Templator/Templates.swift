//
//  Templates.swift
//  Templator
//
//  Created by Ondrej Rafaj on 16/04/2019.
//

import Foundation
import Vapor
import Fluent
import Leaf


/// External endpoint authentication closure
public typealias PermissionCheckClosure = ((Route, Request) throws -> EventLoopFuture<Bool>)


/// Main Templator class, needed for setup and template interaction
public final class Templates<Database>: Service where Database: SchemaSupporting & MigrationSupporting {
    
    /// Main error object
    public enum Error: Debuggable {
        
        /// Unauthorized access
        case unauthorized
        
        /// Name already exists
        case nameExists
        
        /// Invalid template data
        case invalidTemplateData
        
        /// Template doesn't exist
        case templateDoesntExist
        
        /// Error identifier
        public var identifier: String {
            switch self {
            case .unauthorized:
                return "templator.unauthorized"
            case .nameExists:
                return "templator.name_exists"
            case .invalidTemplateData:
                return "templator.invalid_template_data"
            case .templateDoesntExist:
                return "templator.no_template"
            }
        }
        
        /// Reason for failure
        public var reason: String {
            switch self {
            case .unauthorized:
                return "Authorization rejected by developer"
            case .nameExists:
                return "Template name already exists"
            case .invalidTemplateData:
                return "Template data is invalid"
            case .templateDoesntExist:
                return "Template doesn't exist"
            }
        }
        
    }
    
    /// Setup templator database models
    public static func setup(models migrationConfig: inout MigrationConfig, database: DatabaseIdentifier<Database>) throws {
        migrationConfig.add(model: TemplatorData<Database>.self, database: database)
    }
    
    /// Setup template management routes (optional)
    public static func setup(routes router: Router, database: Database.Type, permissionCheck: PermissionCheckClosure? = nil) throws {
        try RouteController.boot(router: router, database: database, permissionCheck: permissionCheck)
    }
    
    /// Setup services (Leaf for templating and Templates)
    public static func setup(services: inout Services) throws {
        try services.register(LeafProvider())
        services.register(Templates<Database>())
    }
    
    
    /// Initializer
    public init() { }
    
    /// Retrieve a parsed template
    public func get<S, C>(_ source: S.Type, data: C?, on req: Request) throws -> EventLoopFuture<String> where S: AnySource, C: Content {
        let templateFuture = TemplatorData<Database>.query(on: req).filter(\TemplatorData<Database>.name == S.name).first().flatMap(to: String.self) { template in
            guard let template = template else {
                return try S.install(Database.self, on: req)
            }
            return req.eventLoop.newSucceededFuture(result: template.source)
        }
        
        guard let data = data else {
            return templateFuture
        }
        return templateFuture.flatMap(to: String.self) { templateContent in
            guard let templateData = templateContent.data(using: .utf8) else {
                throw Templates<Database>.Error.invalidTemplateData
            }
            let leaf = try req.make(LeafRenderer.self)
            return leaf.render(template: templateData, data).map(to: String.self) { view in
                guard let string = String(data: view.data, encoding: .utf8) else {
                    throw Templates<Database>.Error.invalidTemplateData
                }
                return string
            }
        }
    }
    
}
