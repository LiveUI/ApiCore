//
//  DbCoreModel.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 20/09/2018.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL


/// Default DbCore model protocol
public protocol DbCoreModel: PostgreSQLUUIDModel, Content, Equatable { }


// MARK: - Equating

extension DbCoreModel {
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
}
