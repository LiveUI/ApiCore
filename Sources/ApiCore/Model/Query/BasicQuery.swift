//
//  BasicQuery.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 15/03/2018.
//

import Foundation
import Vapor
import Fluent


/// Basic URL query object
public struct BasicQuery: Codable {
    
    /// Requesting plain text result (comparing to JSON result)
    public let plain: Bool?
    
    /// From (used in pagination, default is 0)
    public let from: Int?
    
    /// Limit number of items per page
    public let limit: Int?
    
    /// Search value
    public let search: String?
    public let jwt: String?
    
}


extension QueryContainer {
    
    /// Basic query values
    public var basic: BasicQuery? {
        let decoded = try? decode(BasicQuery.self)
        return decoded
    }
    
    /// Requesting plain text result (comparing to JSON result)
    public var plain: Bool? {
        return basic?.plain
    }
    
    /// Page (used in pagination, default is 0)
    public var from: Int? {
        return basic?.from
    }
    
    /// Limit number of items per page
    public var limit: Int? {
        return basic?.limit ?? 200
    }
    
    /// Search value
    public var search: String? {
        return basic?.search
    }
    
    public var jwt: String? {
        return basic?.jwt
    }
    
}


extension QueryBuilder {
    
    /// Apply pagination onto a database query
    public func paginate(on req: Request) throws -> Self {
        if let limit = req.query.basic?.limit {
            let from = req.query.basic?.from ?? 0
            return range(lower: from, upper: (from + limit))
        }
        return self
    }
    
}
