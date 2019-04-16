//
//  Source.swift
//  Templator
//
//  Created by Ondrej Rafaj on 16/04/2019.
//

import Foundation
import Fluent
import Vapor


/// Source template (type erased)
public protocol AnySource {
    
    static var name: String { get }
    static var link: String { get }
    static var deletable: Bool { get }
    
}


/// Source template
public protocol Source: AnySource {
    
    /// Database generic specifying type of a used database
    associatedtype Database where Database: SchemaSupporting
    
}


extension AnySource {
    
    /// Install a source
    static func install<Database>(_ database: Database.Type, on req: Request) throws -> EventLoopFuture<String> where Database: SchemaSupporting & MigrationSupporting {
        let client: Client = try req.make()
        return client.get(link).flatMap(to: String.self) { response in
            return response.http.body.consumeData(on: req).flatMap(to: String.self) { data in
                guard let string = String(data: data, encoding: .utf8) else {
                    throw Templates<Database>.Error.invalidTemplateData
                }
                let oneFuture: EventLoopFuture<TemplatorData<Database>?> = try TemplatorManager.one(name: name, on: req)
                return oneFuture.flatMap(to: String.self) { object in
                    guard let object = object else {
                        let object = TemplatorData<Database>.from(source: self, sourceCode: string)
                        return object.save(on: req).map(to: String.self) { object in
                            return string
                        }
                    }
                    object.source = string
                    return object.save(on: req).map(to: String.self) { object in
                        return string
                    }
                }
            }
            }.catchMap({ err -> (String) in
                let path = templatesFolderPath.appendingPathComponent(name).appendingPathExtension("leaf")
                guard FileManager.default.fileExists(atPath: path.path) else {
                    throw Templates<Database>.Error.templateDoesntExist
                }
                let content = try String(contentsOf: path)
                return content
            })
    }
    
    /// Path to the templates folder
    static var templatesFolderPath: URL {
        let config = DirectoryConfig.detect()
        let url: URL = URL(fileURLWithPath: config.workDir).appendingPathComponent("Resources/Templates")
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                fatalError("Unable to create templates folder at path: \(url.path)")
            }
        }
        return url
    }
    
}
