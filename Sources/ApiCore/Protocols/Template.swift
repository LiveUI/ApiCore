//
//  Template.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 10/09/2018.
//

import Foundation
import Vapor


/// Template protocol
public protocol Template {
    static var name: String { get }
    
    static func exists(type: Templates.Which) -> Bool
    static func create(type: Templates.Which)
}


extension Template {
    
    /// Path to the templates folder
    public static var path: URL {
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
