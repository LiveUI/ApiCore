//
//  BasicQuery.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 15/03/2018.
//

import Foundation
import Vapor
import Fluent


public struct BasicQuery: Codable {
    
    public let plain: Bool?
    public let page: Int?
    public let limit: Int?
    public let search: String?
    public let jwt: String?
    
}


extension QueryContainer {
    
    public var basic: BasicQuery? {
        let decoded = try? decode(BasicQuery.self)
        return decoded
    }
    
    public var plain: Bool? {
        return basic?.plain
    }
    
    public var page: Int? {
        return basic?.page
    }
    
    public var limit: Int? {
        return basic?.limit ?? 200
    }
    
    public var search: String? {
        return basic?.search
    }
    
    public var jwt: String? {
        return basic?.jwt
    }
    
}


extension QueryBuilder {
    
    public func paginate(on req: Request) throws -> Self {
        if let limit = req.query.basic?.limit {
            let page = req.query.basic?.page ?? 0
            let lower = (page * limit)
            return range(lower: lower, upper: (lower + limit))
        }
        return self
    }
    
}
