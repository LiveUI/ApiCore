//
//  Request+Files.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 22/01/2018.
//

import Foundation
import Vapor


extension Request {
    
    /// Return file data from the request
    public var fileData: Future<Data> {
        let mb = Double(ApiCore.configuration.server.maxUploadFilesize ?? 50)
        return http.body.consumeData(max: Int(Filesize.megabyte(mb).value), on: self)
    }
    
}

