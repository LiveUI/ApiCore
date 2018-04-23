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
    try ApiCore.boot(router: router)
    services.register(router, as: Router.self)
    
    // Go!
    try ApiCore.configure(&config, &env, &services)
}
