//
//  CoreManager+Location.swift
//  FileCore
//
//  Created by Ondrej Rafaj on 25/05/2018.
//

import Foundation
@_exported import FileCore
@_exported import Vapor


extension CoreManager {
    
    /// Public URL for file
    public func url(for path: String, on req: Request) -> String {
        if ApiCoreBase.configuration.storage.s3.enabled {
            return ":)"
        } else {
            let url = req.serverURL().appendingPathComponent(path).absoluteString
            return url
        }
    }
    
}
