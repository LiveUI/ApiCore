//
//  Authenticator.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 18/04/2019.
//

import Foundation
import Vapor


public struct Authenticator: Content {
    
    public var button: String
    
    public var name: String
    
    public var identifier: String
    
    public var icon: String
    
    public var type: String
    
    public init(button: String, name: String, identifier: String, icon: String, type: String = "OAUTH") {
        self.button = button
        self.name = name
        self.identifier = identifier
        self.icon = icon
        self.type = type
    }
    
}
