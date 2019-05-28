//
//  ApiCoreBase+Storage.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 17/04/2019.
//

import Foundation
import S3
import ResourceCache


extension ApiCoreBase {
    
    static func setupStorage(_ services: inout Services) throws {
        services.register(
            ResourceCache.Cache(
                Cache.Config(
                    storagePath: configuration.storage.local.root.finished(with: "/").appending("ResourceCache")
                )
            )
        )
        if configuration.storage.s3.enabled {
            let config = S3Signer.Config(accessKey: configuration.storage.s3.accessKey,
                                         secretKey: configuration.storage.s3.secretKey,
                                         region: configuration.storage.s3.region,
                                         securityToken: configuration.storage.s3.securityToken
            )
            try services.register(s3: config, defaultBucket: configuration.storage.s3.bucket)
            try services.register(fileCoreManager: .s3(
                config,
                configuration.storage.s3.bucket
                ))
        } else {
            try services.register(fileCoreManager: .local(LocalConfig(root: configuration.storage.local.root)))
        }
    }
    
}
