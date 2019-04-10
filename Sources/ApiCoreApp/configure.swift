import Foundation
import Vapor
import ApiCore
import MailCore


public func configure(_ config: inout Vapor.Config, _ env: inout Vapor.Environment, _ services: inout Services) throws {
    print("Starting ApiCore by LiveUI")
    sleep(1)
    Env.print()
    
    // Go!
    try ApiCoreBase.configure(&config, &env, &services)
    
    // Register routes
    let router = EngineRouter.default()
    try ApiCoreBase.boot(router: router)
    services.register(router, as: Router.self)
}
