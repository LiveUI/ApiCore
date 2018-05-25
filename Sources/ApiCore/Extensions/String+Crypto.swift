//
//  String+Crypto.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 14/01/2018.
//

import Foundation
import Vapor
import Crypto


extension String {
    
    /// Hashed password
    public func passwordHash(_ req: Request) throws -> String {
        if req.environment == .production {
            let hashedString = try BCrypt.hash(self)
            return hashedString
        } else {
            return self
        }
    }
    
    /// Base64 decoded string
    public var base64Decoded: String? {
        guard let decodedData = Data(base64Encoded: self), let decodedString = String(data: decodedData, encoding: .utf8) else {
            return nil
        }
        return decodedString
    }
    
    /// MD5 of a string
    public var md5: String? {
        guard let data = data(using: .utf8) else { return nil }
        return try? MD5.hash(data).hexEncodedString()
    }
    
}
