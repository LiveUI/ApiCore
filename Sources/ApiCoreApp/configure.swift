import Foundation
import Vapor
import GithubLogin
import ApiCore
import MailCore


public func configure(_ config: inout Vapor.Config, _ env: inout Vapor.Environment, _ services: inout Services) throws {
    print("Starting ApiCore by LiveUI")
    sleep(1)
    Env.print()
    
    // Register routes
    let router = EngineRouter.default()
    try ApiCoreBase.boot(router: router)
    services.register(router, as: Router.self)
    
    let githubLogin = try GithubLoginManager(
        Config(
            appId: "d7fa16dce40d56ac5cac",
            sharedSecret: "6275a667d97b68bd0747334c33b95b25c790f072"
        ),
        router: router
    )
    services.register { _ in
        githubLogin
    }
    
    // Go!
    try ApiCoreBase.configure(&config, &env, &services)
}
