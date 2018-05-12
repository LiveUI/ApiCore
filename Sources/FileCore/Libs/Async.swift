//
//  Async.swift
//  FileCore
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation


/// Async stuff handling
class Async {
    
    /// Default background dispatch queue
    static var dispatchQueue: DispatchQueue = {
        return DispatchQueue(label: "io.liveui.filecore")
    }()
    
}
