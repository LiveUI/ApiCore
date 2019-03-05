//
//  Link.swift
//  GithubLogin
//
//  Created by Ondrej Rafaj on 05/03/2019.
//

import Foundation
import Vapor


struct Link: Content {
    
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case value = "link"
    }
    
    init(_ config: Config) {
        value = URLBuilder.link(config: config)
    }
    
}
