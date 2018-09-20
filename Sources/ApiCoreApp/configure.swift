import Foundation
import Vapor
//import DbCore
import ApiCore
import MailCore


public func configure(_ config: inout Config, _ env: inout Vapor.Environment, _ services: inout Services) throws {
    print("Starting ApiCore by LiveUI")
    sleep(10)
    Env.print()
    
    // Register routes
    let router = EngineRouter.default()
    try ApiCoreBase.boot(router: router)
    services.register(router, as: Router.self)
    
    // Go!
    try ApiCoreBase.configure(&config, &env, &services)
}
