//
//  Environment.swift
//  BoostCore
//
//  Created by Ondrej Rafaj on 08/02/2018.
//

import Foundation



public struct Env {
    
    /// All available environmental values
    static var data: [String: String] {
        return ProcessInfo.processInfo.environment as [String: String]
    }
    
    /// Print all available environmental values
    public static func print() {
        Swift.print("Environment variables:")
        data.sorted(by: { (item1, item2) -> Bool in
            item1.key < item2.key
        }).forEach { item in
            Swift.print("\t\(item.key)=\(item.value)")
        }
        Swift.print("\n")
    }
    
}
