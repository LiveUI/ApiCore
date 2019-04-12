//
//  GitlabUser.swift
//  GitlabLogin
//
//  Created by Ondrej Rafaj on 27/03/2019.
//

import Foundation


struct GitlabUser: Codable {
    
    struct Identity: Codable {
        let provider: String?
        let externUID: String?
        
        enum CodingKeys: String, CodingKey {
            case provider = "provider"
            case externUID = "extern_uid"
        }
    }
    
    let id: Int
    let username: String
    let email: String
    let name: String?
    let state: String?
    let avatarURL: String?
    let webURL: String?
    let createdAt: String?
    let isAdmin: Bool?
    let bio: String?
    let location: String?
    let publicEmail: String?
    let skype: String?
    let linkedin: String?
    let twitter: String?
    let websiteURL: String?
    let organization: String?
    let lastSignInAt: String?
    let confirmedAt: String?
    let themeID: Int?
    let lastActivityOn: String?
    let colorSchemeID: Int?
    let projectsLimit: Int?
    let currentSignInAt: String?
    let identities: [Identity]?
    let canCreateGroup: Bool?
    let canCreateProject: Bool?
    let twoFactorEnabled: Bool?
    let external: Bool?
    let privateProfile: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case username = "username"
        case email = "email"
        case name = "name"
        case state = "state"
        case avatarURL = "avatar_url"
        case webURL = "web_url"
        case createdAt = "created_at"
        case isAdmin = "is_admin"
        case bio = "bio"
        case location = "location"
        case publicEmail = "public_email"
        case skype = "skype"
        case linkedin = "linkedin"
        case twitter = "twitter"
        case websiteURL = "website_url"
        case organization = "organization"
        case lastSignInAt = "last_sign_in_at"
        case confirmedAt = "confirmed_at"
        case themeID = "theme_id"
        case lastActivityOn = "last_activity_on"
        case colorSchemeID = "color_scheme_id"
        case projectsLimit = "projects_limit"
        case currentSignInAt = "current_sign_in_at"
        case identities = "identities"
        case canCreateGroup = "can_create_group"
        case canCreateProject = "can_create_project"
        case twoFactorEnabled = "two_factor_enabled"
        case external = "external"
        case privateProfile = "private_profile"
    }
    
}
