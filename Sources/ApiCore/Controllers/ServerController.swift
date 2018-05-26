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


/// Server routes
public class ServerController: Controller {
    
    /// Setup routes
    public static func boot(router: Router) throws {
        // Get server info
        router.get("info") { req -> Info in
            let fm = try req.makeFileCore()
            let info = Info(
                name: ApiCoreBase.configuration.server.name,
                url: req.serverURL().absoluteString,
                icons: try IconSize.all.sorted(by: { $0.rawValue < $1.rawValue }).map({
                    let url = try fm.url(for: "server/image/\($0.rawValue)", on: req)
                    return Info.Icon(size: $0, url: url)
                })
            )
            return info
        }
        
        // Upload a server image (admin only)
        router.post("server", "image") { req -> Future<Response> in
            return try req.me.isSystemAdmin().flatMap(to: Response.self) { isAdmin in
                guard isAdmin else {
                    throw ErrorsCore.HTTPError.notAuthorizedAsAdmin
                }
                // Accept image max 500Kb
                return req.http.body.consumeData(max: 1_000_000, on: req).flatMap({ data in
                    guard data.isWebImage() else {
                        throw ImageError.invalidImageFormat
                    }
                    
                    return try Logo.create(from: data, on: req).map({ _ in
                        return try req.response.noContent()
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
            let fm = try req.makeFileCore()
            return try fm.get(file: "server/image/\(size.rawValue)", on: req).map(to: Response.self) { data in
                let response = try req.response.image(data)
                return response
            }
        }
        
        // Retrieve a server image (large)
        router.get("server", "image") { req -> Future<Response> in
            let fm = try req.makeFileCore()
            return try fm.get(file: "server/image/\(IconSize.large.rawValue)", on: req).map(to: Response.self) { data in
                let response = try req.response.image(data)
                return response
            }
        }
        
        // Remove server images (all sizes)
        router.delete("server", "image") { req -> Future<Response> in
            let fm = try req.makeFileCore()
            return try fm.delete(file: "server/image", on: req).map(to: Response.self) { data in
                return try req.response.noContent()
            }
        }
    }
    
}
