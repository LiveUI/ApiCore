//
//  System.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 29/04/2019.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL


/// Systems array type typealias
public typealias Systems = [System]


/// System object
public final class System: DbCoreModel {
    
    /// Object id
    public var id: DbIdentifier?
    
    /// Team Id (optional, per team only, overrides basic system settings)
    public var teamId: DbIdentifier?
    
    /// Key
    public var key: String
    
    /// Value
    public var value: String
    
    /// Initializer
    init(teamId: DbIdentifier? = nil, key: String, value: String) {
        self.teamId = teamId
        self.key = key
        self.value = value
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case teamId = "team_id"
        case key
        case value
    }
    
}

// MARK: - Migrations

extension System: Migration {
    
    /// Migration preparations
    public static func prepare(on connection: ApiCoreConnection) -> Future<Void> {
        return Database.create(self, on: connection) { (schema) in
            schema.field(for: \.id, isIdentifier: true)
            schema.field(for: \.teamId, type: .uuid)
            schema.field(for: \.key, type: .varchar(64), .notNull)
            schema.field(for: \.value, type: .text, .notNull)
        }
    }
    
    /// Migration reverse
    public static func revert(on connection: ApiCoreConnection) -> Future<Void> {
        return Database.delete(System.self, on: connection)
    }
    
}

