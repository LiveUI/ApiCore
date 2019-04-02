//
//  String+Crypto.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 14/01/2018.
//

import Foundation
import Vapor
import Crypto
import ErrorsCore


extension String {
    
    /// Hashed password
    public func passwordHash(_ worker: BasicWorker) throws -> String {
        let cost = try Environment.detect().isRelease ? 12 : 4
        let hashedString = try BCrypt.hash(self, cost: cost)
        return hashedString
    }
    
    /// Verify password
    public func verify(against storedHash: String) -> Bool {
        let ok = (try? BCrypt.verify(self, created: storedHash)) ?? false
        return ok
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
    
    /// SHA256 of a string
    public func sha() throws -> String {
        guard let data = data(using: .utf8) else {
            throw ErrorsCore.HTTPError.missingAuthorizationData
        }
        return try SHA256.hash(data).hexEncodedString()
    }
    
}
