//
//  ServerIcon.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 08/01/2019.
//

import Foundation
import FileCore
import Vapor


public class ServerIcon {
    
    public static func icon(size: IconSize = .regular, on req: Request) throws -> EventLoopFuture<Data> {
        return try icon(exists: size, on: req).flatMap() { exists in
            guard exists else {
                let data = Logo.data
                return try Logo.create(from: data, on: req).map() { _ in
                    return data
                }
            }
            let fm = try req.makeFileCore()
            let fileName = "server/image/\(size.rawValue)"
            return try fm.get(file: fileName, on: req)
        }
    }
    
    public static func icon(exists size: IconSize, on req: Request) throws -> EventLoopFuture<Bool> {
        let fm = try req.makeFileCore()
        let fileName = "server/image/\(size.rawValue)"
        return try fm.exists(file: fileName, on: req)
    }
    
}
