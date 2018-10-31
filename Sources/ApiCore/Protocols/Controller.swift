//
//  Controller.swift
//  App
//
//  Created by Ondrej Rafaj on 09/12/2017.
//

import Foundation
import Vapor


/// Controller protocol
public protocol Controller {
    
    /// Boot controller and register all it's routes
    static func boot(router: Router, secure: Router, debug: Router) throws
    
}
