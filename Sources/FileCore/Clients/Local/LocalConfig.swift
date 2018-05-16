//
//  LocalConfig.swift
//  FileCore
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation


/// Local filesystem configuration
public struct LocalConfig {
    
    /// Root folder for storing files
    public let root: String
    
    /// Initializer
    ///
    /// - parameters:
    ///     - root: Root folder to store all files
    public init(root: String) {
        self.root = root
    }
    
}
