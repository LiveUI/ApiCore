//
//  EventLoop+Future.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 22/03/2018.
//

import Foundation
import Vapor
import NIO


extension EventLoop {
    
    /// New succeeded Void future
    public func newSucceededVoidFuture() -> Future<Void> {
        return newSucceededFuture(result: Void())
    }
    
}
