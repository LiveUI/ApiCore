//
//  Info.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 25/05/2018.
//

import Foundation
import Vapor


/// Server info object
public struct Info: Content {
    
    /// Icons
    public struct Icon: Codable {
        
        /// Size
        public let size: IconSize
        
        /// URL
        public let url: String
        
    }
    
    /// Config
    public struct Config: Codable {
        
        /// Team configuration (single or multi)
        public let singleTeam: Bool
        
        /// New registrations are enabled/disabled
        public let allowRegistrations: Bool
        
        /// Is system registrations restricted to certain domains only?
        public let allowedRegistrationDomains: [String]
        
        /// Allow invitations
        public let allowInvitations: Bool
        
        /// Users are restricted to send invitations to certain domains only
        public let domainInvitationsRestricted: Bool
        
        /// Github login enabled
        public let githubEnabled: Bool
        
        /// Github teams
        public let allowedGithubTeams: [String]
        
        /// Gitlab login enabled
        public let gitlabEnabled: Bool
        
        /// Gitlab teams
        public let allowedGitlabGroups: [String]
        
        enum CodingKeys: String, CodingKey {
            case singleTeam = "single_team"
            case allowRegistrations = "allow_registrations"
            case allowedRegistrationDomains = "allowed_registration_domains"
            case allowInvitations = "allow_invitations"
            case domainInvitationsRestricted = "domain_invitations_restricted"
            case githubEnabled = "github_enabled"
            case allowedGithubTeams = "allowed_github_teams"
            case gitlabEnabled = "gitlab_enabled"
            case allowedGitlabGroups = "allowed_gitlab_groups"
        }
        
    }
    
    /// Server name
    public let name: String
    
    /// Server subtitle
    public let subtitle: String?
    
    /// Server URL
    public let url: String
    
    /// Server URL
    public let interface: String?
    
    /// Server icons
    public let icons: [Icon]
    
    /// Server config
    public let config: Config
    
    
    /// Initializer
    ///
    /// - Parameter req: Request
    /// - Throws: yes
    public init(_ req: Request) throws {
        let fm = try req.makeFileCore()
        name = ApiCoreBase.configuration.server.name
        subtitle = ApiCoreBase.configuration.server.subtitle
        url = req.serverURL().absoluteString
        interface = ApiCoreBase.configuration.server.interface
        icons = try IconSize.all.sorted(by: { $0.rawValue < $1.rawValue }).map({
            let url = try fm.url(for: "server/image/\($0.rawValue)", on: req)
            return Info.Icon(size: $0, url: url)
        })
        config = Config(
            singleTeam: ApiCoreBase.configuration.general.singleTeam,
            allowRegistrations: ApiCoreBase.configuration.auth.allowRegistrations,
            allowedRegistrationDomains: ApiCoreBase.configuration.auth.allowedDomainsForRegistration,
            allowInvitations: ApiCoreBase.configuration.auth.allowInvitations,
            domainInvitationsRestricted: !ApiCoreBase.configuration.auth.allowedDomainsForInvitations.isEmpty,
            githubEnabled: ApiCoreBase.configuration.auth.github.enabled,
            allowedGithubTeams: ApiCoreBase.configuration.auth.github.teams,
            gitlabEnabled: ApiCoreBase.configuration.auth.gitlab.enabled,
            allowedGitlabGroups: ApiCoreBase.configuration.auth.gitlab.groups
        )
    }
    
}
