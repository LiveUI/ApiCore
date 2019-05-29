//
//  SettingsController.swift
//  SettingsCore
//
//  Created by Ondrej Rafaj on 15/03/2018.
//

import Foundation
import Vapor
import ApiCore
import ErrorsCore
import FluentPostgreSQL


public class SettingsController: Controller {
    
    public static func boot(router: Router, secure: Router, debug: Router) throws {
        router.get("settings") { (req) -> Future<Response> in
            return Setting.query(on: req).all().flatMap(to: Response.self) { settings in
                if req.query.plain == true  {
                    var dic: [String: String] = [:]
                    settings.forEach({ setting in
                        dic[setting.name] = setting.config
                    })
                    return try dic.asJson().asResponse(.ok, to: req)
                } else {
                    return try settings.asResponse(.ok, to: req)
                }
            }
        }
        
        router.get("settings", DbIdentifier.parameter) { (req) -> Future<Response> in
            let id = try req.parameters.next(DbIdentifier.self)
            return Setting.query(on: req).filter(\Setting.id == id).first().flatMap(to: Response.self) { setting in
                guard let setting = setting else {
                    throw ErrorsCore.HTTPError.notFound
                }
                if req.query.plain == true  {
                    return try setting.config.asResponse(.ok, to: req)
                } else {
                    return try setting.asResponse(.ok, to: req)
                }
            }
        }
        
        secure.post("settings") { (req) -> Future<Response> in
            return try req.me.isSystemAdmin().flatMap(to: Response.self) { admin in
                guard admin else {
                    throw ErrorsCore.HTTPError.notAuthorizedAsAdmin
                }
                return try req.content.decode(Setting.self).flatMap(to: Response.self) { updatedSetting in
                    return try updatedSetting.save(on: req).asResponse(.created, to: req)
                }
            }
        }
        
        secure.put("settings", DbIdentifier.parameter) { (req) -> Future<Setting> in
            return try req.me.isSystemAdmin().flatMap(to: Setting.self) { admin in
                guard admin else {
                    throw ErrorsCore.HTTPError.notAuthorizedAsAdmin
                }
                let id = try req.parameters.next(DbIdentifier.self)
                return try req.content.decode(Setting.self).flatMap(to: Setting.self) { updatedSetting in
                    return Setting.query(on: req).filter(\Setting.id == id).first().flatMap(to: Setting.self) { setting in
                        guard let setting = setting else {
                            throw ErrorsCore.HTTPError.notFound
                        }
                        updatedSetting.id = setting.id
                        return updatedSetting.save(on: req)
                    }
                }
            }
        }
        
        secure.delete("settings", DbIdentifier.parameter) { (req) -> Future<Response> in
            return try req.me.isSystemAdmin().flatMap(to: Response.self) { admin in
                guard admin else {
                    throw ErrorsCore.HTTPError.notAuthorizedAsAdmin
                }
                let id = try req.parameters.next(DbIdentifier.self)
                return try Setting.query(on: req).filter(\Setting.id == id).delete().asResponse(to: req)
            }
        }
        
    }
}
