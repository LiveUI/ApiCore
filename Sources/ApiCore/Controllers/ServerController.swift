//
//  ServerController.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 16/05/2018.
//

import Foundation
import Vapor
import ErrorsCore
import FileCore
import ImageCore

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif


/// Server routes
public class ServerController: Controller {
    
    /// Setvarroutes
    public static func boot(router: Router, secure: Router, debug: Router) throws {
        // Get server info
        router.get("info") { req -> EventLoopFuture<Info> in
            func info(_ system: System) throws -> Info {
                var info = try Info(req)
                info.icons = info.icons.map({ icon in
                    var icon = icon
                    icon.url.append("?guid=" + system.value)
                    return icon
                })
                return info
            }
            return SystemManager.get(for: "LogoUUID", on: req).flatMap({ system in
                guard let system = system else {
                    return SystemManager.set(value: UUID().uuidString, for: "LogoUUID", on: req).map({ system in
                        return try info(system)
                    })
                }
                return try req.eventLoop.newSucceededFuture(result: info(system))
            })
        }
        
        router.get("authenticators") { req -> [Authenticator] in
            var authenticators: [Authenticator] = []
            if ApiCoreBase.configuration.auth.allowLogin {
                authenticators.append(
                    Authenticator(
                        button: req.serverURL().appendingPathComponent("auth").absoluteString,
                        name: "Login",
                        identifier: "login",
                        icon: "users",
                        color: nil,
                        type: .basic
                    )
                )
            }
            if ApiCoreBase.configuration.auth.github.enabled {
                authenticators.append(
                    Authenticator(
                        button: req.serverURL().appendingPathComponent("auth/github/login").absoluteString,
                        name: "Github",
                        identifier: "github",
                        icon: "github",
                        color: "000000"
                    )
                )
            }
            if ApiCoreBase.configuration.auth.gitlab.enabled {
                authenticators.append(
                    Authenticator(
                        button: req.serverURL().appendingPathComponent("auth/gitlab/login").absoluteString,
                        name: "GitLab",
                        identifier: "gitlab",
                        icon: "gitlab",
                        color: "D75D38"
                    )
                )
            }
            for auth in Auth.authenticators {
                authenticators.append(
                    Authenticator(
                        button: req.serverURL().appendingPathComponent(auth.link).absoluteString,
                        name: auth.name,
                        identifier: auth.name.lowercased(),
                        icon: auth.icon,
                        color: auth.color
                    )
                )
            }
            return authenticators
        }
        
        // Upload a server image (admin only)
        secure.post("server", "image") { req -> Future<Response> in
            return try req.me.isSystemAdmin().flatMap(to: Response.self) { isAdmin in
                guard isAdmin else {
                    throw ErrorsCore.HTTPError.notAuthorizedAsAdmin
                }
                // Accept image max 1Mb
                return req.http.body.consumeData(max: 1_000_000, on: req).flatMap({ data in
                    guard data.isWebImage() else {
                        throw ImageError.invalidImageFormat
                    }
                    
                    return try Logo.create(from: data, on: req).flatMap({ _ in
                        return SystemManager.set(value: UUID().uuidString, for: "LogoUUID", on: req).map({ _ in
                            return try req.response.noContent()
                        })
                    })
                })
            }
        }
        
        // TODO: Refactor the following Logo (server image) methods so they are content within the Logo struct!!
        // Retrieve a server image of specific size
        router.get("server", "image", Int.parameter) { req -> Future<Response> in
            let sizeString = try req.parameters.next(Int.self)
            guard let size = IconSize(rawValue: sizeString) else {
                throw Logo.Error.invalidSize
            }
            return try ServerIcon.icon(size: size, on: req).mapToImageResponse(on: req)
        }
        
        // Retrieve a server image (favicon)
        router.get("server", "favicon") { req -> Future<Response> in
            return try ServerIcon.icon(size: .favicon, on: req).mapToImageResponse(on: req)
        }
        
        // Retrieve a server image (large)
        router.get("server", "image") { req -> Future<Response> in
            return try ServerIcon.icon(size: .large, on: req).mapToImageResponse(on: req)
        }
        
        // Remove server images (all sizes)
        secure.delete("server", "image") { req -> Future<Response> in
            let fm = try req.makeFileCore()
            return try fm.delete(file: "server/image", on: req).map(to: Response.self) { data in
                return try req.response.noContent()
            }
        }
        
        // Check server security
        secure.get("server", "security") { req -> Future<ServerSecurity> in
            let security = try SecurityAudit.issues(for: req)
            let configuration = try ConfigurationAudit.issues(for: req)
            return security.flatMap(to: ServerSecurity.self) { issues in
                let sec = ServerSecurity()
                sec.issues = issues
                return configuration.map(to: ServerSecurity.self) { issues in
                    sec.issues.append(contentsOf: issues)
                    return sec
                }
            }
        }
        
        // Get the current commit (if available)
        debug.get("server", "commit") { req -> String in
            let config = DirectoryConfig.detect()
            let url = URL(fileURLWithPath: config.workDir).appendingPathComponent("Resources").appendingPathComponent("commit.txt")
            if FileManager.default.fileExists(atPath: url.path), let commit = try? String(contentsOfFile: url.path) {
                return commit
            } else {
                throw ErrorsCore.HTTPError.notFound
            }
        }
        
        // Flush stdout
        debug.get("server", "flush") { req -> String in
            fflush(stdout)
            return "done"
        }
    }
    
}
