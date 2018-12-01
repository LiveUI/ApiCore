//
//  Model+Helpers.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 01/12/2018.
//

import Foundation
import ErrorsCore


extension DbCoreModel {
    
    public func guaranteedId() throws -> DbIdentifier {
        guard let id = id else {
            throw ErrorsCore.HTTPError.missingId
        }
        return id
    }
    
}
