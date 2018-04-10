//
//  Template.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 23/03/2018.
//

import Foundation
import Vapor
import Leaf
import Fluent


public protocol Template {
    static var name: String { get }
    static var string: String { get }
    static var html: String? { get }
}


extension Template {
    
    private static var path: URL {
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
    
    public static var stringPath: URL {
        var url = path
        url.appendPathComponent(name)
        url.appendPathExtension("string")
        url.appendPathExtension("temp")
        return url
    }
    
    public static var htmlPath: URL {
        var url = path
        url.appendPathComponent(name)
        url.appendPathExtension("html")
        url.appendPathExtension("temp")
        return url
    }
    
    public static func parsed<M>(_ type: Templates.Which, model: M? = nil, on req: Request) throws -> Future<String> where M: Content {
        guard let content = type == .string ? string : html, let data = content.data(using: .utf8) else {
            throw Templates.Problem.templateUnavailable
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
                throw Templates.Problem.templateUnavailable
            }
            return string
        }
    }
    
    public typealias ParsedDoubleType = (string: String, html: String?)
    
    public static func parsed<M>(model: M? = nil, on req: Request) throws -> Future<ParsedDoubleType> where M: Content {
        if html == nil {
            return try parsed(.string, model: model, on: req).map(to: ParsedDoubleType.self) { string in
                return (string: string, html: nil)
            }
        }
        return try parsed(.string, model: model, on: req).flatMap(to: ParsedDoubleType.self) { string in
            return try parsed(.html, model: model, on: req).map(to: ParsedDoubleType.self) { html in
                return (string: string, html: html)
            }
        }
    }
    
}
