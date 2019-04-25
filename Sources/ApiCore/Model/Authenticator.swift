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
    
    public var color: String?
    
    public var type: AuthType
    
    public init(button: String, name: String, identifier: String, icon: String, color: String?, type: AuthType = .oauth) {
        self.button = button
        self.name = name
        self.identifier = identifier
        self.icon = icon
        self.color = color
        self.type = type
    }
    
}
