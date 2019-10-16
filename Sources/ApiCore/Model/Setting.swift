//
//  Setting.swift
//  SettingsCore
//
//  Created by Ondrej Rafaj on 15/03/2018.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
import ErrorsCore


public typealias Settings = [Setting]


public final class Setting: DbCoreModel {
    
    public var id: DbIdentifier?
    public var name: String
    public var config: String
    
    public init(id: DbIdentifier? = nil, name: String, config: String) {
        self.id = id
        self.name = name
        self.config = config
    }
    
}

// MARK: - Migrations

extension Setting: Migration {
    
    public static var idKey: WritableKeyPath<Setting, DbIdentifier?> = \Setting.id
    
    public static func prepare(on connection: ApiCoreConnection) -> Future<Void> {
        return Database.create(self, on: connection) { (schema) in
            schema.field(for: \.id, isIdentifier: true)
            schema.field(for: \.name)
            schema.field(for: \.config, type: .text)
        }
    }
    
    public static func revert(on connection: ApiCoreConnection) -> Future<Void> {
        return Database.delete(Setting.self, on: connection)
    }
    
}

extension Array where Element == Setting {
    
    public func asDictionary() -> [String: String] {
        return reduce([String: String]()) { (dict, setting) -> [String: String] in
            var dict = dict
            dict[setting.name] = setting.config
            return dict
        }
    }
    
}
