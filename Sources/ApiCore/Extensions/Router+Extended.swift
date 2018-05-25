//
//  Router+Extended.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 17/03/2018.
//

import Foundation
import Vapor

extension Router {
    
    /// OPTIONS request
    @discardableResult public func options<T>(_ path: PathComponentsRepresentable..., use closure: @escaping (Request) throws -> T) -> Route<Responder> where T: ResponseEncodable {
        return self.on(.OPTIONS, at: path, use: closure)
    }
    
}
