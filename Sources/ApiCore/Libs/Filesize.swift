
//
//  Filesize.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 22/01/2018.
//

import Foundation


/// Filesize
public enum Filesize {
    
    /// Kilobytes with ammount
    case kilobyte(Double)
    
    /// Megabytes with ammount
    case megabyte(Double)
    
    /// Gigabytes with ammount
    case gigabyte(Double)
    
    /// Calculated value
    public var value: Double {
        switch self {
        case .kilobyte(let no):
            return (no * 1000)
        case .megabyte(let no):
            return ((no * 1000) * 1000)
        case .gigabyte(let no):
            return (((no * 1000) * 1000) * 1000)
        }
    }
    
}
