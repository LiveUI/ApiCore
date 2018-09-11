//
//  Data+Tools.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 11/09/2018.
//

import Foundation


extension Data {
    
    public func asUTF8String() -> String? {
        return String(data: self, encoding: .utf8)
    }
    
}
