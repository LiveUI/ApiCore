//
//  TeamUser.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 01/03/2018.
//

import Foundation
import Fluent
//import DbCore
import Vapor


public final class TeamUser: ModifiablePivot, DbCoreModel {
    
    /// Left JOIN table
    public typealias Left = Team
    
    /// Right JOIN table
    public typealias Right = User
    
    /// Left JOIN Id key
    public static var leftIDKey: WritableKeyPath<TeamUser, DbIdentifier> {
        return \.teamId
    }
    
    /// Right JOIN Id key
    public static var rightIDKey: WritableKeyPath<TeamUser, DbIdentifier> {
        return \.userId
    }
    
    /// Object Id
    public var id: DbIdentifier?
    
    /// Team Id
    public var teamId: DbIdentifier
    
    /// User Id
    public var userId: DbIdentifier
    
    // MARK: Initialization
    
    /// Initialization
    public init(_ left: TeamUser.Left, _ right: TeamUser.Right) throws {
        teamId = try left.requireID()
        userId = try right.requireID()
    }
    
}

// MARK: - Migrations

extension TeamUser: Migration {
    
    /// Migration preparations
    public static func prepare(on connection: ApiCoreConnection) -> Future<Void> {
        return Database.create(self, on: connection) { (schema) in
            schema.field(for: \TeamUser.id)
            schema.field(for: \TeamUser.teamId, type: .uuid, .notNull)
            schema.field(for: \TeamUser.userId, type: .uuid, .notNull)
        }
    }
    
    /// Migration reverse (DROP TABLE)
    public static func revert(on connection: ApiCoreConnection) -> Future<Void> {
        return Database.delete(TeamUser.self, on: connection)
    }
}
