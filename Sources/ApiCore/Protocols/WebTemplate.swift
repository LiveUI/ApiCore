//
//  WebTemplate.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 10/09/2018.
//

import Foundation
import Vapor
import Leaf
import Fluent


/// Template protocol
public protocol WebTemplate: Template {
    static var html: String { get }
}


extension WebTemplate {
    
    /// HTML template
    public static var htmlPath: URL {
        var url = path
        url.appendPathComponent(name)
        url.appendPathExtension("html")
        url.appendPathExtension("temp")
        return url
    }
    
    /// Parse model onto a template
    public static func parsed<M>(_ type: Templates.Which, model: M? = nil, on req: Request) throws -> Future<String> where M: Content {
        guard let data = (try? Data(contentsOf: htmlPath)) else {
            throw Templates.Error.templateUnavailable
        }
        
        let leaf = try req.make(LeafRenderer.self)
        let output: Future<View>
        if let model = model {
            output = leaf.render(template: data, model)
        } else {
            output = leaf.render(template: data, [String: String]())
        }
        return output.map(to: String.self) { view in
            guard let string = String.init(data: view.data, encoding: .utf8) else {
                throw Templates.Error.templateUnavailable
            }
            return string
        }
    }
    
    /// Does template exist?
    public static func exists(type: Templates.Which) -> Bool {
        return FileManager.default.fileExists(atPath: htmlPath.path)
    }
    
    /// Create a template
    public static func create(type: Templates.Which) {
        do {
            try html.write(to: htmlPath, atomically: true, encoding: .utf8)
        } catch {
            fatalError("Unable to save default template \(name) to path: \(htmlPath)")
        }
    }
    
}
