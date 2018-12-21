//
//  UsersManager.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 21/12/2018.
//

import Foundation
import Vapor
import FluentPostgreSQL


public class UsersManager {
    
    public static func get(user email: String, password: String, on req: Request) -> EventLoopFuture<User?> {
        return User.query(on: req).filter(\User.email == email).first().map(to: User?.self) { user in
            guard let user = user, let userPassword = user.password, password.verify(against: userPassword) else {
                return nil
            }
            return user
        }
    }
    
}
