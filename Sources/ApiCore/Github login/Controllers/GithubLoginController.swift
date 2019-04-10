//
//  GithubLoginController.swift
//  GithubLogin
//
//  Created by Ondrej Rafaj on 05/03/2019.
//

import Foundation
import Vapor
import Imperial
import ErrorsCore


class GithubLoginController: Controller {
    
    public enum Error: FrontendError {
        
        case missingRedirectLink
        case unableToProcessUserData
        case unableToGenerateRedirectLink
        
        public var status: HTTPStatus {
            switch self {
            case .missingRedirectLink:
                return .badRequest
            case .unableToProcessUserData, .unableToGenerateRedirectLink:
                return .internalServerError
            }
        }
        
        public var identifier: String {
            switch self {
            case .missingRedirectLink:
                return "github.missing_redirect_link"
            case .unableToProcessUserData:
                return "github.bad_user_data"
            case .unableToGenerateRedirectLink:
                return "github.callback_link_error"
            }
        }
        
        public var reason: String {
            switch self {
            case .missingRedirectLink:
                return "Missing redirect link; You can set it up by calling `/auth/github/login?link={authenticated_redirect_link}`"
            case .unableToProcessUserData:
                return "Unable to process user data"
            case .unableToGenerateRedirectLink:
                return "Unable to generate the redirect link"
            }
        }
        
    }
    
    public static var config: GithubConfig?
    
    static func boot(router: Router, secure: Router, debug: Router) throws {
        let redirectKey: String = "github-session-redirect"
        
        struct Redirect: Codable {
            let link: String
        }
        
        let sessions = router.grouped("auth", "github").grouped(SessionsMiddleware.self)
        
        guard let config = self.config else {
            fatalError("Github config not set")
        }
        
        // Redirect to the login
        try sessions.oAuth(
            from: GitHub.self,
            authenticate: "login",
            authenticateCallback: { req in
                guard let redirect = try? req.query.decode(Redirect.self) else {
                    throw Error.missingRedirectLink
                }
                try req.session().set(redirectKey, to: redirect)
                return req.eventLoop.newSucceededFuture(result: Void())
            },
            callback: "callback",
            scope: config.scopes,
            completion: { (req, githubToken) in
                let client = try req.make(Client.self)
                let headers: HTTPHeaders = [
                    "Accept": "application/json",
                    "Authorization": "token \(githubToken)"
                ]
                let userHTTPRequest = HTTPRequest(
                    method: HTTPMethod.GET,
                    url: "\(config.api.finished(with: "/"))user",
                    headers: headers
                )
                let userRequest = Request(http: userHTTPRequest, using: req)
                return client.send(userRequest).flatMap(to: ResponseEncodable.self) { userResponse in
                    let emailsHTTPRequest = HTTPRequest(
                        method: HTTPMethod.GET,
                        url: "\(config.api.finished(with: "/"))user/emails",
                        headers: headers
                    )
                    let emailsRequest = Request(http: emailsHTTPRequest, using: req)
                    return client.send(emailsRequest).map(to: ResponseEncodable.self) { emailsResponse in
                        let decoder = JSONDecoder()
                        
                        guard
                            let userData = userResponse.http.body.data, let user = try? decoder.decode(GithubUser.self, from: userData)
                            else {
                                throw Error.unableToProcessUserData
                        }
                        guard
                            let emailsData = emailsResponse.http.body.data, let emails = try? decoder.decode(Emails.self, from: emailsData)
                            else {
                                throw Error.unableToProcessUserData
                        }
                        guard
                            var info = try? UserInfo(user: user, emails: emails, githubToken: githubToken),
                            let redirectLink = try? req.session().get(redirectKey, as: Redirect.self),
                            let redirectUrl = URL(string: redirectLink.link)
                            else {
                                throw Error.missingRedirectLink
                        }
                        // Add company check
                        return try UsersManager.userFromExternalAuthenticationService(info, on: req).flatMap(to: Response.self) { apiCoreUser in
                            return try AuthManager.authData(request: req, user: apiCoreUser).map(to: Response.self) { authData in
                                info.token = authData.0.token
                                guard let url = try? redirectUrl.append(userInfo: info, on: req), let unwrappedUrl = url else {
                                    throw Error.unableToGenerateRedirectLink
                                }
                                
                                return req.redirect(to: unwrappedUrl.absoluteString)
                            }
                        }
                    }
                }
        })
    }
    
}
