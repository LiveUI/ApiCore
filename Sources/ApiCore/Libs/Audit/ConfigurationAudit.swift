//
//  ConfigurationAudit.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 08/01/2019.
//

import Foundation
import Vapor


public class ConfigurationAudit: Audit {
    
    public static var customIssues: [ServerSecurity.Issue] = []
    
    public static func issues(for req: Request) throws -> EventLoopFuture<[ServerSecurity.Issue]> {
        var array: [EventLoopFuture<ServerSecurity.Issue?>] = []
        try array.append(check(icon: req))
        return array.map(to: [ServerSecurity.Issue].self, on: req, { issues in
            var arr = issues.compactMap({ $0 })
            arr.append(contentsOf: customIssues)
            arr.append(contentsOf: nonFutureChecks())
            return arr
        })
    }
    
    public static func nonFutureChecks() -> [ServerSecurity.Issue] {
        var arr: [ServerSecurity.Issue] = []
        if ApiCoreBase.configuration.mail.mailgun.domain == "sandbox-domain.mailgun.org" ||
            ApiCoreBase.configuration.mail.mailgun.key == "secret-key" {
            arr.append(
                ServerSecurity.Issue(
                    category: .danger,
                    code: "email_not_configured",
                    issue: "Email has not been configured"
                )
            )
        }
        return arr
    }
    
    public static func check(icon req: Request) throws -> EventLoopFuture<ServerSecurity.Issue?> {
        return try ServerIcon.icon(exists: .favicon, on: req).map(to: ServerSecurity.Issue?.self) { exists in
            if !exists {
                return ServerSecurity.Issue(
                    category: .warning,
                    code: "server_icon_not_set",
                    issue: "Server icon has not been set"
                )
            } else {
                return nil
            }
        }
    }
    
}
