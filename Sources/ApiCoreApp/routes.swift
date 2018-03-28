import Routing
import Vapor
import ApiCore


public func routes(_ router: Router) throws {
    try ApiCore.boot(router: router)
}
