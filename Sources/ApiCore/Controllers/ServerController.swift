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
    
    public enum Error: FrontendError {
        case invalidSize
        case imageCorrupted
        case imageTooSmall(Size)
        case imageNotSquare(Size)
        
        /// Error HTTP status
        public var status: HTTPStatus {
            return .preconditionFailed
        }
        
        /// Error code
        public var identifier: String {
            switch self {
            case .invalidSize:
                return "server.invalid_size"
            case .imageCorrupted:
                return "server.image_corrupted"
            case .imageTooSmall:
                return "server.image_too_small"
            case .imageNotSquare:
                return "server.image_not_square"
            }
        }
        
        /// Reason for failure
        public var reason: String {
            switch self {
            case .invalidSize:
                return "Invalid image size; Available sizes are 64, 128, 192, 256 & 512 px"
            case .imageCorrupted:
                return "Image seems to be corrupted"
            case .imageTooSmall(let size):
                return "Image needs to be at least 512x512 px large; uploaded image is \(size.toString())"
            case .imageNotSquare(let size):
                return "Image needs to be square; uploaded image is \(size.toString())"
            }
        }
        
    }
    
    /// Setup routes
    public static func boot(router: Router) throws {
        // Upload a server image (admin only)
        router.post("server", "image") { req -> Future<Response> in
            return try req.me.isSystemAdmin().flatMap(to: Response.self) { isAdmin in
                guard isAdmin else {
                    throw ErrorsCore.HTTPError.notAuthorizedAsAdmin
                }
                // Accept image max 500Kb
                return req.http.body.consumeData(max: 500_000, on: req).flatMap({ data in
                    guard data.isWebImage(), let mime = data.imageFileMediaType() else {
                        throw ImageError.invalidImageFormat
                    }
                    
                    let image = try Image(data: data)
                    
                    let size = image.size
                    
                    // Check image is square
                    if size.width != size.height {
                        throw Error.imageNotSquare(size)
                    }
                    
                    // Image too small
                    if size.width < 512 {
                        throw Error.imageTooSmall(size)
                    }
                    
                    // Resize all images
                    guard let at1x = image.resizedTo(width: IconSize.at1x.rawValue), let at1xData = try? at1x.export(as: .png),
                        let at2x = image.resizedTo(width: IconSize.at2x.rawValue), let at2xData = try? at2x.export(as: .png),
                        let at3x = image.resizedTo(width: IconSize.at3x.rawValue), let at3xData = try? at3x.export(as: .png),
                        let reg = image.resizedTo(width: IconSize.regular.rawValue), let regData = try? reg.export(as: .png),
                        let large = image.resizedTo(width: IconSize.large.rawValue), let largeData = try? large.export(as: .png) else {
                            throw Error.imageCorrupted
                    }
                    
                    // Save all images
                    let fm = try req.makeFileCore()
                    return try fm.save(file: at1xData, to: "Server/image-\(IconSize.at1x.rawValue)", mime: mime, on: req).flatMap({ _ in
                        return try fm.save(file: at2xData, to: "Server/image-\(IconSize.at2x.rawValue)", mime: mime, on: req).flatMap({ _ in
                            return try fm.save(file: at3xData, to: "Server/image-\(IconSize.at3x.rawValue)", mime: mime, on: req).flatMap({ _ in
                                return try fm.save(file: regData, to: "Server/image-\(IconSize.regular.rawValue)", mime: mime, on: req).flatMap({ _ in
                                    return try fm.save(file: largeData, to: "Server/image-\(IconSize.large.rawValue)", mime: mime, on: req).map({ _ in
                                        return try req.response.noContent()
                                    })
                                })
                            })
                        })
                    })
                })
            }
        }
        
        // Retrieve a server image of specific size
        router.get("server", "image", Int.parameter) { req -> Future<Response> in
            let sizeString = try req.parameters.next(Int.self)
            guard let size = IconSize(rawValue: sizeString) else {
                throw Error.invalidSize
            }
            let fm = try req.makeFileCore()
            return try fm.get(file: "Server/image-\(size.rawValue)", on: req).map(to: Response.self) { data in
                let response = try req.response.image(data)
                return response
            }
        }
        
        // Retrieve a server image (large)
        router.get("server", "image") { req -> Future<Response> in
            let fm = try req.makeFileCore()
            return try fm.get(file: "Server/image-\(IconSize.large.rawValue)", on: req).map(to: Response.self) { data in
                let response = try req.response.image(data)
                return response
            }
        }
    }
    
}
