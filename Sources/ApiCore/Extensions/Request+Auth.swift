//
//  Request+Auth.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 01/03/2018.
//

import Foundation
import Vapor


extension Request {
    
    /// Me instance for current request
    public var me: Me {
        return Me(self)
    }
    
}

