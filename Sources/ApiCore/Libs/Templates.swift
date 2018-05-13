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
        RegistrationTemplate.self
    ]
    
    // MARK: Public interface
    
    /// Install missing templates
    public static func installMissing() {
        for template in templates {
            if !exists(template, type: .string) {
                create(template, type: .string)
            }
            if !exists(template, type: .html) {
                create(template, type: .html)
            }
        }
    }
    
    /// Reset existing templates
    /// *(Changes will be lost)*
    public static func resetTemplates() {
        for template in templates {
            create(template, type: .string)
            create(template, type: .html)
        }
    }
    
    // MARK: Private interface
    
    /// Does template exist?
    private static func exists(_ template: Template.Type, type: Which) -> Bool {
        return FileManager.default.fileExists(atPath: (type == .string ? template.stringPath.path : template.htmlPath.path))
    }
    
    /// Create a template
    private static func create(_ template: Template.Type, type: Which) {
        do {
            if type == .string {
                try template.string.write(to: template.stringPath, atomically: true, encoding: .utf8)
            } else {
                try template.html?.write(to: template.htmlPath, atomically: true, encoding: .utf8)
            }
        } catch {
            if type == .string {
                fatalError("Unable to save default template \(template.name) to path: \(template.stringPath)")
            } else {
                fatalError("Unable to save default template \(template.name) to path: \(template.htmlPath)")
            }
        }
    }
    
}
