//
//  String+Security.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 12/09/2018.
//

import Foundation


extension String {
    
    /// Validate password
    public func validatePassword() throws -> Bool {
        guard count > 6 else {
            throw AuthError.invalidPassword(reason: .tooShort)
        }
        // TODO: Needs stronger validation!!!!!!!!!
        return true
    }
    
}
