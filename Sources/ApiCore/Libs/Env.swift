//
//  Environment.swift
//  BoostCore
//
//  Created by Ondrej Rafaj on 08/02/2018.
//

import Foundation
import Vapor


public struct Env {
    
    /// All available environmental values
    static var data: [String: String] {
        return ProcessInfo.processInfo.environment as [String: String]
    }
    
    /// Print all available environmental values
    public static func print() {
        if (try? Environment.detect()) ?? .production == .development {
            Swift.print("Environment variables:")
            data.sorted(by: { (item1, item2) -> Bool in
                item1.key < item2.key
            }).forEach { item in
                Swift.print("\t\(item.key)=\(item.value)")
            }
            Swift.print("\n")
        } else {
            Swift.print("Environment variables are only displayed in development/debug mode")
        }
    }
    
}
