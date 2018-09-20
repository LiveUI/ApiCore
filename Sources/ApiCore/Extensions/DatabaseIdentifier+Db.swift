//
//  DatabaseIdentifier+Db.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 20/09/2018.
//

import Foundation
import Fluent
import FluentPostgreSQL


extension DatabaseIdentifier {
    
    /// Default databse identifier
    public static var db: DatabaseIdentifier<ApiCoreDatabase> {
        return .init("psql")
    }
    
}
