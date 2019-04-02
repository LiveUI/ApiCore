//
//  BaseMigration.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 02/04/2019.
//

import Foundation
import Fluent


struct BaseMigration: Migration {
    
    typealias Database = ApiCoreDatabase
    
    static func prepare(on req: ApiCoreConnection) -> EventLoopFuture<Void> {
        let user = try! InstallController.su(on: req)
        user.verified = true
        return user.save(on: req).flatMap(to: Void.self) { user in
            return InstallController.adminTeam.save(on: req).flatMap(to: Void.self) { team in
                var futures = [
                    team.users.attach(user, on: req).flatten()
                ]
                ApiCoreBase.installFutures.forEach({ closure in
                    futures.append(try! closure(req))
                })
                return futures.flatten(on: req)
            }
        }
    }
    
    static func revert(on conn: ApiCoreConnection) -> EventLoopFuture<Void> {
        return User.query(on: conn).delete().flatMap(to: Void.self) { _ in
            return Team.query(on: conn).delete().flatMap(to: Void.self) { _ in
                return TeamUser.query(on: conn).delete()
            }
        }
    }
    
}
