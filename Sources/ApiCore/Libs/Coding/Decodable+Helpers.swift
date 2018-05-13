//
//  Decodable+Helpers.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 07/02/2018.
//

import Foundation


/// Decodable property
public struct DecodableProperty<ModelType> { }


extension DecodableProperty where ModelType: Decodable {
    
    /// Decode (fill) data from JSON file
    public static func fromJSON(file fileUrl: URL) throws -> ModelType {
        let data = try Data(contentsOf: fileUrl)
        return try fromJSON(data: data)
    }
    
    /// Decode (fill) data from JSON file
    public static func fromJSON(path: String) throws -> ModelType {
        let url = URL(fileURLWithPath: path)
        return try fromJSON(file: url)
    }
    
    /// Decode (fill) data from JSON string
    public static func fromJSON(string: String) throws -> ModelType {
        guard let data = string.data(using: .utf8) else {
            fatalError("Invalid string")
        }
        return try fromJSON(data: data)
    }
    
    /// Decode (fill) data from JSON data
    public static func fromJSON(data: Data) throws -> ModelType {
        let decoder = JSONDecoder()
        let object = try decoder.decode(ModelType.self, from: data)
        return object
    }
    
}


/// Decodable helper protocol
public protocol DecodableHelper {
    
    /// Model type
    associatedtype ModelType
    
    /// Quick access to the decodable functionality
    static var decode: DecodableProperty<ModelType>.Type { get }
    
}


public extension DecodableHelper {
    
    /// Quick access to the decodable functionality
    public static var decode: DecodableProperty<ModelType>.Type {
        return DecodableProperty<ModelType>.self
    }
    
}


public protocol JSONDecodable: Decodable, DecodableHelper { }
