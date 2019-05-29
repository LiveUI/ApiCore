//
//  Templates.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 29/05/2019.
//

import Foundation
import Vapor
import ErrorsCore
import Leaf


public class Templator: Service {
    
    public struct Templates: Codable {
        
        public struct Template: Codable {
            
            public let name: String
            
            public let link: String
            
        }
        
        public let name: String
        
        public let items: [Template]
        
    }
    
    public enum Error: FrontendError {
        
        case templateMissing(String)
        case invalidTemplateData(String)
        
        public var status: HTTPStatus {
            return .internalServerError
        }
        
        public var identifier: String {
            return "templator.missing_template"
        }
        
        public var reason: String {
            return "Template is missing"
        }
        
    }
    
    public let packageUrl: String
    
    public init(packageUrl: String) throws {
        self.packageUrl = packageUrl
        
        try loadTemplates()
    }
    
    public func get<C>(name: String, data: C?, on req: Request) throws -> EventLoopFuture<String> where C: Content {
        guard let templateContent = try? String(contentsOf: url(fileName: name)) else {
            throw Error.templateMissing(name)
        }
        guard let data = data else {
            return req.eventLoop.newSucceededFuture(result: templateContent)
        }
        guard let templateData = templateContent.data(using: .utf8) else {
            throw Error.invalidTemplateData(name)
        }
        let leaf = try req.make(LeafRenderer.self)
        return leaf.render(template: templateData, data).map(to: String.self) { view in
            guard let string = String(data: view.data, encoding: .utf8) else {
                throw Error.invalidTemplateData(name)
            }
            return string
        }
    }
    
    public func reset() throws {
        try loadTemplates()
    }
    
    // MARK Private interface
    
    private func url(fileName: String) -> URL {
        var url = URL(
            fileURLWithPath: ApiCoreBase.configuration.storage.local.root
        )
        url.appendPathComponent("templates")
        url.appendPathComponent("email")
        
        do {
            try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true)
        } catch {
            fatalError("Unable to create templates folder structure")
        }
        
        url.appendPathComponent(fileName)
        url.appendPathExtension("leaf")
        return url
    }
    
    func loadTemplates() throws {
        guard let url = URL(string: packageUrl) else {
            fatalError("Invalid template package URL: (\(packageUrl))")
        }
        let packageData = try Data(contentsOf: url)
        guard packageData.count > 0 else {
            fatalError("Invalid template package: (\(packageUrl))")
        }
        let package = try JSONDecoder().decode(Templates.self, from: packageData)
        for template in package.items {
            guard let url = URL(string: template.link) else {
                fatalError("Invalid template URL: (\(template.name) - \(template.link))")
            }
            let content = try Data(contentsOf: url)
            let fileUrl = self.url(fileName: template.name)
            try content.write(to: fileUrl)
        }
    }
    
}
