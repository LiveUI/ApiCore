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
    
    static func prepare(on conn: ApiCoreConnection) -> EventLoopFuture<Void> {
        let user = try! InstallController.su(on: conn)
        user.verified = true
        return user.save(on: conn).flatMap(to: Void.self) { user in
            return InstallController.adminTeam.save(on: conn).flatMap(to: Void.self) { team in
                var futures = [
                    team.users.attach(user, on: conn).flatten()
                ]
                ApiCoreBase.installFutures.forEach({ closure in
                    futures.append(try! closure(conn))
                })
                return futures.flatten(on: conn)
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
