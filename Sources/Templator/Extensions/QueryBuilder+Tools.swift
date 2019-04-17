//
//  QueryBuilder+Tools.swift
//  Templator
//
//  Created by Ondrej Rafaj on 16/04/2019.
//

import Foundation
import Vapor
import Fluent


/// Basic URL query object
struct BasicQuery: Codable {
    
    /// Search value
    let search: String?
    
}

extension QueryContainer {
    
    /// Basic query values
    var basic: BasicQuery? {
        let decoded = try? decode(BasicQuery.self)
        return decoded
    }
    
}

extension QueryBuilder {
    
    func search<Database>(on req: Request) throws -> Self where Result == TemplatorData<Database> {
        if let search = req.query.basic?.search, !search.isEmpty {
            // TODO: Make search ~~ (LIKE)!!!!!
            return filter(\Result.name == search)
        }
        return self
    }
    
}
