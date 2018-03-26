import Foundation
import Vapor
import DbCore
import ApiCore
import MailCore


public func configure(_ config: inout Config, _ env: inout Vapor.Environment, _ services: inout Services) throws {
    print("Starting Boost")
    Env.print()
    
    // Register routes
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // Database
    let db = DbCore.envConfig(defaultDatabase: "boost")
    
    // Emails
    guard let mailGunApi = Environment.get("MAILGUN_API"),  let mailGunDomain = Environment.get("MAILGUN_DOMAIN") else {
        fatalError("Mailgun API key or domain is missing")
    }
    let mail = Mailer.Config.mailgun(key: mailGunApi, domain: mailGunDomain)
    Mailer(config: mail, registerOn: &services)
    
    // Go!
    try ApiCore.configure(databaseConfig: db, &config, &env, &services)
}
