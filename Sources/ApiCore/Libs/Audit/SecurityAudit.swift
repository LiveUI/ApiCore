//
//  SecurityAudit.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 08/01/2019.
//

import Foundation
import Vapor


public class SecurityAudit: Audit {
    
    public static var customIssues: [ServerSecurity.Issue] = []
    
    public static func issues(for req: Request) throws -> EventLoopFuture<[ServerSecurity.Issue]> {
        var array: [EventLoopFuture<ServerSecurity.Issue?>] = []
        array.append(check(defaultLoginOn: req))
        return array.map(to: [ServerSecurity.Issue].self, on: req, { issues in
            var arr = issues.compactMap({ $0 })
            arr.append(contentsOf: customIssues)
            arr.append(contentsOf: nonFutureChecks())
            return arr
        })
    }
    
    public static func nonFutureChecks() -> [ServerSecurity.Issue] {
        var arr: [ServerSecurity.Issue] = []
        if ApiCoreBase.configuration.jwtSecret == "secret" {
            arr.append(
                ServerSecurity.Issue(
                    category: .danger,
                    code: "default_secret_for_jwt",
                    issue: "Default JWT secret is set to be 'secret' which is, well, not very secret. This can be set as an ENV variable 'APICORE_JWT_SECRET'."
                )
            )
        }
        return arr
    }
    
    public static func check(defaultLoginOn req: Request) -> EventLoopFuture<ServerSecurity.Issue?> {
        return UsersManager.get(user: "core@liveui.io", password: "sup3rS3cr3t", on: req).map(to: ServerSecurity.Issue?.self) { user in
            if user != nil {
                return ServerSecurity.Issue(
                    category: .danger,
                    code: "default_user_exists",
                    issue: "Default user with publicly known username and password exists (core@liveui.io/sup3rS3cr3t). Please change the password or delete the user."
                )
            }
            return nil
        }
    }
    
}
