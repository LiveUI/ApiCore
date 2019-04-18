//
//  GitlabLoginController.swift
//  GitlabLogin
//
//  Created by Ondrej Rafaj on 05/03/2019.
//

import Foundation
import Vapor
import Imperial
import ErrorsCore


class GitlabLoginController: Controller {
    
    public enum Error: FrontendError {
        
        case missingRedirectLink
        case unableToProcessUserData
        case unableToGenerateRedirectLink
        case invalidOrganization
        
        public var status: HTTPStatus {
            switch self {
            case .missingRedirectLink:
                return .badRequest
            case .unableToProcessUserData, .unableToGenerateRedirectLink:
                return .internalServerError
            case .invalidOrganization:
                return .unauthorized
            }
        }
        
        public var identifier: String {
            switch self {
            case .missingRedirectLink:
                return "gitlab.missing_redirect_link"
            case .unableToProcessUserData:
                return "gitlab.bad_user_data"
            case .unableToGenerateRedirectLink:
                return "gitlab.callback_link_error"
            case .invalidOrganization:
                return "gitlab.invalid_organizations"
            }
        }
        
        public var reason: String {
            switch self {
            case .missingRedirectLink:
                return "Missing redirect link; You can set it up by calling `/auth/gitlab/login?link={authenticated_redirect_link}`"
            case .unableToProcessUserData:
                return "Unable to process user data"
            case .unableToGenerateRedirectLink:
                return "Unable to generate the redirect link"
            case .invalidOrganization:
                return "Not a member of any connected Gitlab organization"
            }
        }
        
    }
    
    public static var config: GitlabConfig?
    
    static func boot(router: Router, secure: Router, debug: Router) throws {
        let redirectKey: String = "gitlab-session-redirect"
        
        struct Redirect: Codable {
            let link: String
        }
        
        let sessions = router.grouped("auth", "gitlab").grouped(SessionsMiddleware.self)
        
        guard let config = self.config else {
            fatalError("Gitlab config not set")
        }
        
        // Redirect to the login
        try sessions.oAuth(
            from: Gitlab.self,
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
            completion: { (req, gitlabToken) in
                let client = try req.make(Client.self)
                let headers: HTTPHeaders = [
                    "Accept": "application/json",
                    "Authorization": "Bearer \(gitlabToken)"
                ]
                let userHTTPRequest = HTTPRequest(
                    method: HTTPMethod.GET,
                    url: "\(config.api.finished(with: "/"))user",
                    headers: headers
                )
                let userRequest = Request(http: userHTTPRequest, using: req)
                return client.send(userRequest).flatMap(to: ResponseEncodable.self) { userResponse in
                    let decoder = JSONDecoder()
                    guard
                        let userData = userResponse.http.body.data, let user = try? decoder.decode(GitlabUser.self, from: userData)
                        else {
                            throw Error.unableToProcessUserData
                    }
                    
                    guard
                        var info = try? GitlabUserInfo(user: user, gitlabToken: gitlabToken),
                        let redirectLink = try? req.session().get(redirectKey, as: Redirect.self),
                        let redirectUrl = URL(string: redirectLink.link)
                        else {
                            throw Error.missingRedirectLink
                    }
                    
                    // TODO: Implement groups!!!!!!
                    
//                    if !ApiCoreBase.configuration.auth.gitlab.groups.isEmpty {
//                        var ok = false
//                        let companies = user.organization?.split(separator: ",").map({ String($0).trimmingCharacters(in: .whitespacesAndNewlines) })
//                        ApiCoreBase.configuration.auth.gitlab.groups.forEach({ company in
//                            if companies?.contains(company) ?? false {
//                                ok = true
//                            }
//                        })
//                        guard ok else {
//                            throw Error.invalidOrganization
//                        }
//                    }
                    return try UsersManager.userFromExternalAuthenticationService(info, on: req).flatMap(to: ResponseEncodable.self) { apiCoreUser in
                        return try AuthManager.authData(request: req, user: apiCoreUser).map(to: ResponseEncodable.self) { authData in
                            info.token = authData.0.token
                            guard let url = try? redirectUrl.append(userInfo: info, on: req), let unwrappedUrl = url else {
                                throw Error.unableToGenerateRedirectLink
                            }
                            
                            return req.redirect(to: unwrappedUrl.absoluteString)
                        }
                    }
                }
        })
    }
    
}
