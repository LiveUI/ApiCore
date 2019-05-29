//
//  EmailTemplateData.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 29/05/2019.
//

import Foundation
import Vapor


public protocol EmailTemplateData: class, Content {
    
    var user: User.Display? { get set }
    
    var info: Info? { get set }
    
    var settings: [String: String]? { get set }
    
}

extension EmailTemplateData {
    
    public func setup(user: User.Display? = nil, on req: Request) throws -> EventLoopFuture<Void> {
        self.user = try user ?? req.me.user().asDisplay()
        self.info = try Info(req)
        return Setting.query(on: req).all().map() { settings in
            self.settings = settings.asDictionary()
            return Void()
        }
    }
    
}
