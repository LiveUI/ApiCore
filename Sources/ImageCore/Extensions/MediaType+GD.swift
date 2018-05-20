//
//  MediaType+GD.swift
//  ImageCore
//
//  Created by Ondrej Rafaj on 19/05/2018.
//

import Foundation
import Vapor
import SwiftGD


/// Method helpers for MediaType/GD
extension MediaType {
    
    /// Convert MediaType to a SwiftGD compatible format
    public func gdMime() -> ImportableFormat? {
        switch self {
        case .gif:
            return .gif
        case .jpeg:
            return .jpg
        case .png:
            return .png
        default:
            return nil
        }
    }
    
}
