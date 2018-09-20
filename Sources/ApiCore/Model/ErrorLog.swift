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
//import DbCore
import ErrorsCore


/// Error logs array type typealias
public typealias ErrorLogs = [ErrorLog]


/// ErrorLog object
public final class ErrorLog: DbCoreModel {
    
    /// Object Id
    public var id: DbIdentifier?
    
    /// Date added/created
    public var added: Date
    
    /// URL
    public var uri: String
    
    /// Error
    public var error: String
    
    /// Initializer
    public init(id: DbIdentifier? = nil, request req: Request, error: Swift.Error) {
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
    public static func prepare(on connection: ApiCoreConnection) -> Future<Void> {
        return Database.create(self, on: connection) { (schema) in
            schema.field(for: \.id, isIdentifier: true)
            schema.field(for: \.added, type: .timestamp)
            schema.field(for: \.uri, type: .varchar(250))
            schema.field(for: \.error, type: .text)
        }
    }
    
    /// Revert migrations
    public static func revert(on connection: ApiCoreConnection) -> Future<Void> {
        return Database.delete(ErrorLog.self, on: connection)
    }
    
}
