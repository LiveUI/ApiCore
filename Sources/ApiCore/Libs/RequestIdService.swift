//
//  RequestIdService.swift
//  BoostCore
//
//  Created by Ondrej Rafaj on 07/03/2018.
//

import Foundation
import Vapor


final class RequestIdService: Service, ServiceType {
    
    /// Make service
    static func makeService(for worker: Container) throws -> RequestIdService {
        return RequestIdService()
    }
    
    /// Generate random UUID
    let uuid = UUID()
    
}

extension Request {
    
    /// Session Id
    ///     *Unique for each request*
    public var sessionId: UUID {
        return try! self.privateContainer.make(RequestIdService.self).uuid
    }
    
}
