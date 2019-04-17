//
//  RegistrationTemplate.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 23/03/2018.
//

import Foundation
import Vapor
import Templator


public class WebTemplateInfoScreen: TemplateSource {
    
    /// Template model
    public struct Model: Content {
        
        /// Action link model
        public struct Action: Codable {
            
            /// Link (href attribute)
            public var link: String
            
            /// Title attribute of the link
            public var title: String
            
            /// Text of the link
            public var text: String
            
        }
        
        /// Title of the page
        public var title: String
        
        /// Text of the page
        public var text: String
        
        /// User
        public var user: User
        
        /// Finish recovery link
        public var action: Action?
        
        /// System wide template data
        public var system: FrontendSystemData
        
        /// Initializer
        public init(title: String, text: String, user: User, action: Action? = nil, on req: Request) throws {
            self.title = title
            self.text = text
            self.user = user
            self.action = action
            system = try FrontendSystemData(req)
        }
        
    }
    
    /// Template name
    public static var name: String = "web.info-message"
    
    public static var link: String = "https://raw.githubusercontent.com/LiveUI/ApiCore/master/Resources/Templates/web.info-message.leaf"
    
    public static var deletable: Bool = false
    
}
