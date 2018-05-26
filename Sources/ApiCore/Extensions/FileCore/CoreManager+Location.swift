//
//  CoreManager+Location.swift
//  FileCore
//
//  Created by Ondrej Rafaj on 25/05/2018.
//

import Foundation
@_exported import FileCore
@_exported import Vapor
import S3


extension CoreManager {
    
    /// Public URL for file
    public func url(for path: String, on req: Request) throws -> String {
        if ApiCoreBase.configuration.storage.s3.enabled {
            let s3 = try req.makeS3Client()
            let url = try s3.url(fileInfo: path, on: req)
            return url.absoluteString
        } else {
            let url = req.serverURL().appendingPathComponent(path).absoluteString
            return url
        }
    }
    
}
