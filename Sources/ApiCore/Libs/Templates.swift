//
//  Templates.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 23/03/2018.
//

import Foundation
import ErrorsCore
import Vapor


/// Templates
public class Templates {
    
    /// Template error
    public enum Error: FrontendError {
        
        /// Template is not available
        case templateUnavailable
        
        /// Error code
        public var identifier: String {
            return "template.template_not_available"
        }
        
        /// Reason to fail
        public var reason: String {
            return "Template not available"
        }
        
        /// HTTP status code
        public var status: HTTPStatus {
            return .notImplemented
        }
        
    }
    
    /// Template data selector
    public enum Which {
        case string
        case html
    }
    
    /// Available templates
    static var templates: [Template.Type] = [
        RegistrationTemplate.self, // Confirm registration email
        InvitationTemplate.self, // Confirm invitation email
        PasswordRecoveryEmailTemplate.self, // Recovery email
        PasswordRecoveryTemplate.self, // Web page
        InfoWebTemplate.self // Info message (web)
    ]
    
    // MARK: Public interface
    
    /// Install missing templates
    public static func installMissing() {
        for template in templates {
            if !template.exists(type: .string) {
                template.create(type: .string)
            }
            if !template.exists(type: .html) {
                template.create(type: .html)
            }
        }
    }
    
    /// Reset existing templates
    /// *(Changes will be lost)*
    public static func resetTemplates() {
        for template in templates {
            template.create(type: .string)
            template.create(type: .html)
        }
    }
    
}
