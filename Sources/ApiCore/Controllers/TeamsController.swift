//
//  TeamsController.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 17/01/2018.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
import DbCore
import ErrorsCore


/// Teams controller
class TeamsController: Controller {
    
    /// Error
    enum Error: FrontendError {
        case userNotFound
        case cantAddYourself
        case userAlreadyMember
        case userNotMember
        case youAreTheLastUser
        case unableToDeleteAdminTeam
        
        var identifier: String {
            switch self {
            case .userNotFound:
                return "team_error.user_not_found"
            case .cantAddYourself:
                return "team_error.cant_add_yourself"
            case .userAlreadyMember:
                return "team_error.user_already_member"
            case .userNotMember:
                return "team_error.user_not_member"
            case .youAreTheLastUser:
                return "team_error.you_are_last_user"
            case .unableToDeleteAdminTeam:
                return "team_error.unable_delete_admin_team"
            }
        }
        
        var reason: String {
            switch self {
            case .userNotFound:
                return "User not found"
            case .cantAddYourself:
                return "One just can not add themselves to another peoples team my friend!"
            case .userAlreadyMember:
                return "User is already a member of the team"
            case .userNotMember:
                return "User is not a member of the team"
            case .youAreTheLastUser:
                return "You are the last user in this team; Please delete the team instead"
            case .unableToDeleteAdminTeam:
                return "Can't delete admin team"
            }
        }
        
        var status: HTTPStatus {
            switch self {
            case .userNotFound:
                return .notFound
            default:
                return .conflict
            }
        }
    }
    
    enum LinkAction {
        case link
        case unlink
    }
    
    static func boot(router: Router) throws {
        router.get("teams") { (req) -> Future<[Team]> in
            let me = try req.me.user()
            return try me.teams.query(on: req).paginate(on: req).all().map({ teams in
                return teams
            })
        }
        
        router.get("teams", DbCoreIdentifier.parameter) { (req) -> Future<Team> in
            let id = try req.parameters.next(DbCoreIdentifier.self)
            return try req.me.verifiedTeam(id: id)
        }
        
        router.post("teams") { (req) -> Future<Response> in
            return try req.content.decode(Team.New.self).flatMap(to: Response.self) { newTeam in
                return try Team.exists(identifier: newTeam.identifier, on: req).flatMap(to: Response.self) { identifierExists in
                    if identifierExists {
                        throw Team.Error.identifierAlreadyExists
                    }
                    return newTeam.asTeam().save(on: req).flatMap(to: Response.self) { team in
                        guard team.id != nil else {
                            throw DbError.insertFailed
                        }
                        let me = try req.me.user()
                        return team.users.attach(me, on: req).flatMap(to: Response.self) { join in
                            return try team.asResponse(.created, to: req)
                        }
                    }
                }
            }
        }   
        
        router.post("teams", "check") { (req) -> Future<Response> in
            return try req.content.decode(Team.Identifier.self).flatMap(to: Response.self) { identifierObject in
                return try Team.exists(identifier: identifierObject.identifier, on: req).map(to: Response.self) { identifierExists in
                    if identifierExists {
                        throw Team.Error.identifierAlreadyExists
                    }
                    return try req.response.success(status: .ok, code: "ok", description: "Identifier available")
                }
            }
        }
        
        router.put("teams", DbCoreIdentifier.parameter) { (req) -> Future<Team> in
            let id = try req.parameters.next(DbCoreIdentifier.self)
            return try req.me.verifiedTeam(id: id).flatMap(to: Team.self, { team in
                return try req.content.decode(Team.New.self).flatMap(to: Team.self) { newTeam in
                    team.name = newTeam.name
                    
                    func save() -> Future<Team> {
                        return team.save(on: req).map(to: Team.self) { team in
                            return team
                        }
                    }
                    
                    if team.identifier == newTeam.identifier {
                        return save()
                    }
                    
                    return try Team.exists(identifier: newTeam.identifier, on: req).flatMap(to: Team.self) { identifierExists in
                        if identifierExists {
                            throw Team.Error.identifierAlreadyExists
                        }
                        
                        team.identifier = newTeam.identifier
                        
                        return save()
                    }
                }
            }).catchMap { (error) -> Team in
                throw ErrorsCore.HTTPError.notFound
            }
        }
        
        router.get("teams", DbCoreIdentifier.parameter, "users") { (req) -> Future<[User]> in
            let id = try req.parameters.next(DbCoreIdentifier.self)
            return try req.me.verifiedTeam(id: id).flatMap(to: [User].self) { (team) -> Future<[User]> in
                return try team.users.query(on: req).paginate(on: req).all()
            }
        }
        
        router.post("teams", DbCoreIdentifier.parameter, "link") { (req) -> Future<Response> in
            return try processLinking(request: req, action: .link)
        }
        
        router.post("teams", DbCoreIdentifier.parameter, "unlink") { (req) -> Future<Response> in
            return try processLinking(request: req, action: .unlink)
        }
        
        router.delete("teams", DbCoreIdentifier.parameter) { (req) -> Future<Response> in
            // TODO: Reload JWT token if successful with new info
            // QUESTION: Should we make sure user has at least one team?
            let teamId = try req.parameters.next(DbCoreIdentifier.self)
            return try req.me.verifiedTeam(id: teamId).flatMap(to: Response.self, { (team) -> Future<Response> in
                if let canDelete = ApiCoreBase.deleteTeamWarning {
                    return canDelete(team).flatMap(to: Response.self, { (error) -> Future<Response> in
                        guard let error = error else {
                            return try delete(team: team, request: req)
                        }
                        throw error
                    })
                }
                else {
                    return try delete(team: team, request: req)
                }
            }).catchMap { (error) -> Response in
                throw ErrorsCore.HTTPError.notFound
            }
        }
    }
    
}


extension TeamsController {
    
    private static func delete(team: Team, request req: Request) throws -> Future<Response> {
        if team.admin {
            throw Error.unableToDeleteAdminTeam
        }
        // TODO: Cascade through all team data (that is not shared with other teams, possibly dleete users too?) !!!!!!
        return team.delete(on: req).map(to: Response.self, { (_) -> Response in
            return try req.response.deleted()
        })
    }
    
    private static func processLinking(request req: Request, action: TeamsController.LinkAction) throws -> Future<Response> {
        let teamId = try req.parameters.next(DbCoreIdentifier.self)
        return try req.me.verifiedTeam(id: teamId).flatMap(to: Response.self) { team in
            return try team.users.query(on: req).all().flatMap(to: Response.self) { teamUsers in
                return try req.content.decode(User.Id.self).flatMap(to: Response.self) { userId in
                    return try User.query(on: req).filter(\User.id == userId.id).first().flatMap(to: Response.self) { user in
                        let me = try req.me.user()
                        guard let user = user else {
                            throw Error.userNotFound
                        }
                        if user.id == me.id && action == .unlink && teamUsers.count <= 1 {
                            throw Error.youAreTheLastUser
                        }
                        if teamUsers.contains(user) {
                            if action == .link {
                                throw Error.userAlreadyMember
                            }
                        } else {
                            if action == .unlink {
                                throw Error.userNotMember
                            }
                        }
                        
                        let res = (action == .link) ? team.users.attach(user, on: req).flatten() : team.users.detach(user, on: req)
                        return res.map(to: Response.self) { (_) -> Response in
                            let message = (action == .link) ? "User has been added to the team" : "User has been removed from the team"
                            return try req.response.success(status: .ok, code: "ok", description: message)
                        }
                    }
                }
            }
        }
    }
    
}
