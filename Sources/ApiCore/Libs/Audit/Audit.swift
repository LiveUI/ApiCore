//
//  Audit.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 08/01/2019.
//

import Foundation
import Vapor


public protocol Audit {
    
    static func issues(for req: Request) throws -> EventLoopFuture<[ServerSecurity.Issue]>
    
}
