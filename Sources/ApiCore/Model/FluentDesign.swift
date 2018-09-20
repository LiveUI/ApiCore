//
//  FluentDesign.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 05/03/2018.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
//import DbCore
import ErrorsCore


/// FluentDesign array type typealias
public typealias FluentDesigns = [FluentDesign]


/// FluentDesigns object
public final class FluentDesign: DbCoreModel {
    
    /// Table (entity) name override
    public static let entity: String = "fluent"
    
    /// Object Id
    public var id: DbIdentifier?
    
    /// Name
    public var name: String
    
    /// Batch
    public var batch: Int
    
    /// Created date
    public var createdAt: Date
    
    /// Updated date
    public var updatedAt: Date
    
    /// Initializer
    public init(id: DbIdentifier? = nil, name: String, batch: Int, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.batch = batch
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
}
