//
//  ServerSecurity.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 21/12/2018.
//

import Foundation
import Vapor
import FluentPostgreSQL


public final class ServerSecurity: Content {
    
    public final class Issue: Content {
        
        public enum Category: String, Codable {
            
            case info
            
            case warning
            
            case danger
            
        }
        
        public var category: Category
        
        public var code: String
        
        public var issue: String
        
        public init(category: Category, code: String, issue: String) {
            self.category = category
            self.code = code
            self.issue = issue
        }
        
    }
    
    public var issues: [Issue] = []
    
}
