//
//  Encodable+Tools.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 22/02/2018.
//

import Foundation
import Vapor


extension Encodable {
    
    /// Convert to a PLIST 2.0 formatted Data
    public func asPropertyList() throws -> Data {
        let jsonData = try JSONEncoder().encode(self)
        let data = try JSONSerialization.jsonObject(with: jsonData, options: [])
        let plistData = try PropertyListSerialization.data(fromPropertyList: data, format: .xml, options: 0)
        return plistData
    }
    
    /// Convert to JSON Data
    public func asJson() throws -> Data {
        let encoder = JSONEncoder()
        if #available(macOS 10.12, *) {
            encoder.dateEncodingStrategy = .iso8601
        } else {
            fatalError("macOS SDK < 10.12 detected, no ISO-8601 JSON support")
        }
        let jsonData = try encoder.encode(self)
        return jsonData
    }
    
}
