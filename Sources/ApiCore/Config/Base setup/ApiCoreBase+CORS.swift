//
//  ApiCoreBase+CORS.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 17/04/2019.
//

import Foundation


extension ApiCoreBase {
    
    static func setupCORS() {
        let corsConfig = CORSMiddleware.Configuration(
            allowedOrigin: .all,
            allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
            allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent],
            exposedHeaders: [
                HTTPHeaderName.authorization.description,
                HTTPHeaderName.contentLength.description,
                HTTPHeaderName.contentType.description,
                HTTPHeaderName.contentDisposition.description,
                HTTPHeaderName.cacheControl.description,
                HTTPHeaderName.expires.description
            ]
        )
        let cors = CORSMiddleware(configuration: corsConfig)
        middlewareConfig.use(cors)
    }
    
}
