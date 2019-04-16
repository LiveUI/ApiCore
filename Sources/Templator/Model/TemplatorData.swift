//
//  TemplatorData.swift
//  Templator
//
//  Created by Ondrej Rafaj on 16/04/2019.
//

import Foundation
import Fluent


final class TemplatorData<Database>: Model where Database: SchemaSupporting {
    
    static var name: String {
        return "Templator"
    }
    
    static var entity: String {
        return "Templator"
    }
    
    typealias ID = UUID
    
    static var idKey: IDKey { return \.id }
    
    var id: UUID?
    var name: String
    
    var source: String
    var link: String?
    
    var deletable: Bool
    
    init(id: UUID? = nil, name: String, source: String, link: String? = nil, deletable: Bool) {
        self.id = id
        self.name = name
        self.source = source
        self.link = link
        self.deletable = deletable
    }
    
}


extension TemplatorData: AnyMigration, Migration where Database: SchemaSupporting & MigrationSupporting {
    
    static func prepare(on connection: Database.Connection) -> Future<Void> {
        return Database.create(TemplatorData<Database>.self, on: connection) { builder in
            builder.field(for: \.id)
            builder.field(for: \.name)
            builder.field(for: \.source)
            builder.field(for: \.link)
            builder.field(for: \.deletable)
        }
    }
    
    static func revert(on connection: Database.Connection) -> Future<Void> {
        return Database.delete(TemplatorData<Database>.self, on: connection)
    }
    
}


extension TemplatorData {
    
    static func from<S>(source sourceObject: S.Type, sourceCode: String = "") -> TemplatorData<Database> where S: AnySource {
        return TemplatorData<Database>(
            name: sourceObject.name,
            source: sourceCode,
            deletable: sourceObject.deletable
        )
    }
    
}
