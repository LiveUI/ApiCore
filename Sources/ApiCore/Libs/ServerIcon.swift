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
        let fm = try req.makeFileCore()
        return try fm.get(file: "server/image/\(IconSize.favicon.rawValue)", on: req)
    }
    
    public static func icon(exists size: IconSize, on req: Request) throws -> EventLoopFuture<Bool> {
        let fm = try req.makeFileCore()
        return try fm.exists(file: "server/image/\(IconSize.favicon.rawValue)", on: req)
    }
    
}
