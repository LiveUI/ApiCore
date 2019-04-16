//
//  TemplatorManager.swift
//  Templator
//
//  Created by Ondrej Rafaj on 16/04/2019.
//

import Foundation
import Vapor
import Fluent


class TemplatorManager {
    
    static func one<Database>(id: UUID, on req: Request) throws -> EventLoopFuture<TemplatorData<Database>?> where Database: SchemaSupporting {
        return TemplatorData<Database>.query(on: req).filter(\TemplatorData.id == id).first()
    }
    
    static func one<Database>(name: String, on req: Request) throws -> EventLoopFuture<TemplatorData<Database>?> where Database: SchemaSupporting {
        return TemplatorData<Database>.query(on: req).filter(\TemplatorData.name == name).first()
    }
    
    static func delete<Database>(id: UUID, database: Database.Type? = nil, on req: Request) throws -> EventLoopFuture<Void> where Database: SchemaSupporting {
        return TemplatorData<Database>.query(on: req).filter(\TemplatorData.id == id).delete()
    }
    
}
