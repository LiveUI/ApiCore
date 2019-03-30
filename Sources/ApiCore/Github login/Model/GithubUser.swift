//
//  GithubUser.swift
//  GithubLogin
//
//  Created by Ondrej Rafaj on 27/03/2019.
//

import Foundation


public struct GithubUser: Codable {
    
    public struct Plan: Codable {
        
        public let name: String?
        public let space: Int?
        public let collaborators: Int?
        public let privateRepos: Int?
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case space = "space"
            case collaborators = "collaborators"
            case privateRepos = "private_repos"
        }
        
    }
    
    public let id: Int
    public let login: String
    public let nodeID: String?
    public let avatarURL: String?
    public let gravatarID: String?
    public let url: String?
    public let htmlURL: String?
    public let followersURL: String?
    public let followingURL: String?
    public let gistsURL: String?
    public let starredURL: String?
    public let subscriptionsURL: String?
    public let organizationsURL: String?
    public let reposURL: String?
    public let eventsURL: String?
    public let receivedEventsURL: String?
    public let type: String?
    public let siteAdmin: Bool?
    public let name: String?
    public let company: String?
    public let blog: String?
    public let location: String?
    public let email: String?
    public let hireable: Bool?
    public let bio: String?
    public let publicRepos: Int?
    public let publicGists: Int?
    public let followers: Int?
    public let following: Int?
    public let createdAt: String?
    public let updatedAt: String?
    public let privateGists: Int?
    public let totalPrivateRepos: Int?
    public let ownedPrivateRepos: Int?
    public let diskUsage: Int?
    public let collaborators: Int?
    public let twoFactorAuthentication: Bool?
    public let plan: Plan?
    
    enum CodingKeys: String, CodingKey {
        case login = "login"
        case id = "id"
        case nodeID = "node_id"
        case avatarURL = "avatar_url"
        case gravatarID = "gravatar_id"
        case url = "url"
        case htmlURL = "html_url"
        case followersURL = "followers_url"
        case followingURL = "following_url"
        case gistsURL = "gists_url"
        case starredURL = "starred_url"
        case subscriptionsURL = "subscriptions_url"
        case organizationsURL = "organizations_url"
        case reposURL = "repos_url"
        case eventsURL = "events_url"
        case receivedEventsURL = "received_events_url"
        case type = "type"
        case siteAdmin = "site_admin"
        case name = "name"
        case company = "company"
        case blog = "blog"
        case location = "location"
        case email = "email"
        case hireable = "hireable"
        case bio = "bio"
        case publicRepos = "public_repos"
        case publicGists = "public_gists"
        case followers = "followers"
        case following = "following"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case privateGists = "private_gists"
        case totalPrivateRepos = "total_private_repos"
        case ownedPrivateRepos = "owned_private_repos"
        case diskUsage = "disk_usage"
        case collaborators = "collaborators"
        case twoFactorAuthentication = "two_factor_authentication"
        case plan = "plan"
    }
    
}
