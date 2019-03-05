//
//  GithubLoginController.swift
//  GithubLogin
//
//  Created by Ondrej Rafaj on 05/03/2019.
//

import Foundation
import Vapor


class GithubLoginController {
    
    static func boot(router: Router, config: Config) throws {
        router.get("auth", "github", "link") { req -> Link in
            return Link(config)
        }
        
        router.get("auth", "github") { req -> EventLoopFuture<Link> in
            let client = try req.make(Client.self)
            let code = try req.query.decode(Code.self)
            let bodyData = try JSONEncoder().encode(
                AccessTokenRequest(
                    config,
                    code: code.value
                )
            )
            print(String(data: bodyData, encoding: .utf8)!)
            let body = HTTPBody(data: bodyData)
            let httpReq = HTTPRequest(
                method: HTTPMethod.POST,
                url: "\(config.server.finished(with: "/"))login/oauth/access_token",
                headers: ["Accept": "application/json"],
                body: body
            )
            let request = Request(http: httpReq, using: req)
            return client.send(request).map(to: Link.self) { res in
                print(res)
                return Link(config)
            }
        }
    }
    
}
