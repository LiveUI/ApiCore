//
//  RegistrationTemplate.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 23/03/2018.
//

import Foundation
import Vapor


public class InfoWebTemplate: WebTemplate {
    
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
    public static var name: String = "info-message-web"
    
    /// Template content
    public static var html: String = """
<!DOCTYPE html>
<html>
    <head>
        <title>#(system.info.name) - #(title)</title>
        <style>
            * {
                font-family: Helvetica, Arial, sans-serif;
                text-align: center;
            }
            body {
                margin-top: 44px;
                width: 300px;
                margin-left: auto;
                margin-right: auto;
            }
            img {
                width: 98px;
                border-radius: 5px;
            }
            h1 {
                font-size: large;
                color: #434343;
            }
            p {
                margin-top: 22px;
            }
            a {
                margin-top: 22px;
                color: white;
                background-color: #5f80b5;
                border: none;
                border-radius: 4px;
                font-size: medium;
                padding-top: 8px;
                padding-bottom: 8px;
                padding-left: 12px;
                padding-right: 12px;
            }
        </style>
        <script type="text/javascript">
            window.onload = function () {
                var input = document.getElementById('password');
                input.focus();
                input.select();
            }
        </script>
    </head>
    <body>
        <p><img src="#(system.info.url)/server/image/256" alt="#(system.info.name)" /></p>
        <h1>#(title)</h1>
        <p>#(text)</p>
        #if(action) {
        <p>
            <a href="#(action.link)" title="#(action.title)">#(action.text)</a>
        </p>
        }
    </body>
</html>
"""
    
}
