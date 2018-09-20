//
//  Me.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 13/05/2018.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
//import DbCore
import ErrorsCore


/// Information about currently authenticated request
public struct Me {
    
    /// Current request
    let request: Request
    
    /// Initializer
    init(_ request: Request) {
        self.request = request
    }
    
    /// Currently authorized user
    public func user() throws -> User {
        let authenticationCache = try request.make(AuthenticationCache.self)
        guard let user = authenticationCache[User.self] else {
            throw ErrorsCore.HTTPError.notAuthorized
        }
        return user
    }
    
    /// Teams for currently authorized user
    public func teams() throws -> Future<Teams> {
        let me = try user()
        return try me.teams.query(on: self.request).all()
    }
    
    /// Is currently authorized user a system admin
    public func isSystemAdmin() throws -> Future<Bool> {
        let me = try user()
        return try me.teams.query(on: self.request).all().map(to: Bool.self) { teams in
            return teams.containsAdmin
        }
    }
    
    /// Team verified to contain currently authorized user
    public func verifiedTeam(id teamId: DbIdentifier) throws -> Future<Team> {
        let me = try user()
        return try me.teams.query(on: self.request).filter(\Team.id == teamId).first().map(to: Team.self) { team in
            guard let team = team else {
                throw ErrorsCore.HTTPError.notFound
            }
            return team
        }
    }
    
}
