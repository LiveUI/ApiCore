//
//  Code.swift
//  GithubLogin
//
//  Created by Ondrej Rafaj on 05/03/2019.
//

import Foundation


struct Code: Codable {
    
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case value = "code"
    }
    
}
