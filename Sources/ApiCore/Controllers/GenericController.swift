//
//  GenericController.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 13/01/2018.
//

import Foundation
import Vapor
import ErrorsCore
import FileCore
import ImageCore


/// Generic/default routes
public class GenericController: Controller {
    
    /// Setup routes
    public static func boot(router: Router) throws {
        router.get(PathComponent.anything) { req in
            return try req.response.badUrl()
        }
        
        router.post(PathComponent.anything) { req in
            return try req.response.badUrl()
        }
        
        router.put(PathComponent.anything) { req in
            return try req.response.badUrl()
        }
        
        router.patch(PathComponent.anything) { req in
            return try req.response.badUrl()
        }
        
        router.delete(PathComponent.anything) { req in
            return try req.response.badUrl()
        }
        
        router.get("teapot") { req in
            return try req.response.teapot()
        }
        
        router.get("ping") { req in
            return try req.response.ping()
        }
        
        // Upload a server image (admin in debug mode only)
        router.post("server", "image") { req -> Future<Response> in
            return try req.me.isSystemAdmin().flatMap(to: Response.self) { isAdmin in
                guard isAdmin else {
                    throw ErrorsCore.HTTPError.notAuthorizedAsAdmin
                }
                return req.http.body.consumeData(max: 2_000_000, on: req).flatMap({ data in
                    guard data.isWebImage(), let ext = data.imageFileExtension, let mime = data.imageFileMediaType() else {
                        throw ImageError.invalidImageFormat
                    }
                    let fm = try req.makeFileCore()
                    return try fm.save(file: data, to: "Server/image.\(ext)", mime: mime, on: req).map({ _ in
                        return try req.response.noContent()
                    })
                })
            }
        }
    }
    
}
