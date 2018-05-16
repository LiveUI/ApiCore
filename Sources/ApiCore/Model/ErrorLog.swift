//
//  Log.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 11/03/2018.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
import DbCore
import ErrorsCore


/// Error logs array type typealias
public typealias ErrorLogs = [ErrorLog]


/// ErrorLog object
public final class ErrorLog: DbCoreModel {
    
    /// Object Id
    public var id: DbCoreIdentifier?
    
    /// Date added/created
    public var added: Date
    
    /// URL
    public var uri: String
    
    /// Error
    public var error: String
    
    /// Initializer
    public init(id: DbCoreIdentifier? = nil, request req: Request, error: Swift.Error) {
        let query = req.http.url.query != nil ? "?\(req.http.url.query!)" : ""
        self.uri = "\(req.http.url.path)\(query)"
        self.added = Date()
        
        if let e = error as? FrontendError {
            self.error = "(\(e.identifier)) - \(e.reason)"
        }
        else {
            self.error = error.localizedDescription
        }
    }
    
}

// MARK: - Migrations

extension ErrorLog: Migration {
    
    /// Prepare migrations
    public static func prepare(on connection: DbCoreConnection) -> Future<Void> {
        return Database.create(self, on: connection) { (schema) in
            schema.addField(type: DbCoreColumnType.id(), name: CodingKeys.id.stringValue, isIdentifier: true)
            schema.addField(type: DbCoreColumnType.datetime(), name: CodingKeys.added.stringValue)
            schema.addField(type: DbCoreColumnType.varChar(250), name: CodingKeys.uri.stringValue)
            schema.addField(type: DbCoreColumnType.text(), name: CodingKeys.error.stringValue)
        }
    }
    
    /// Revert migrations
    public static func revert(on connection: DbCoreConnection) -> Future<Void> {
        return Database.delete(ErrorLog.self, on: connection)
    }
    
}
