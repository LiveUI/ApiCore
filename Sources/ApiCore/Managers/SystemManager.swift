//
//  SystemManager.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 29/04/2019.
//

import Foundation
import Vapor
import Fluent


public final class SystemManager {
    
    /// Set a key value
    public static func set(value: String, for key: String, teamId: DbIdentifier? = nil, on req: Request) -> EventLoopFuture<System> {
        return get(for: key, teamId: teamId, on: req).flatMap({ entry in
            guard let entry = entry else {
                let entry = System(teamId: teamId, key: key, value: value)
                return entry.save(on: req)
            }
            entry.value = value
            return entry.save(on: req)
        })
    }
    
    /// Retrieve a value for a key/team
    public static func get(for key: String, teamId: DbIdentifier? = nil, on req: Request) -> EventLoopFuture<System?> {
        let q = System.query(on: req).filter(\System.key == key)
        q.filter(\System.teamId == teamId)
        return q.first()
    }
    
    /// Retrive the whole config
    public static func get(teamId: DbIdentifier? = nil, on req: Request) -> EventLoopFuture<[System]> {
        let q = System.query(on: req)
        q.filter(\System.teamId == teamId)
        if teamId != nil {
            _ = q.sort(\System.teamId, .ascending)
        }
        return q.all().map({ arr in
            let crossReference = Dictionary(grouping: arr, by: { $0.key })
            var newArr: [System] = []
            for key in crossReference.keys {
                let val = crossReference[key]?.sorted(by: { $0.teamId?.uuidString ?? "" > $1.teamId?.uuidString ?? "" })
                guard let selection = val?.first else { continue }
                newArr.append(selection)
            }
            newArr.sort(by: { $0.key < $1.key })
            
            return newArr
        })
    }
    
}


extension SystemManager {
    
    /// Set a number of key/values at once
    public static func set(_ valueDoubles: [(value: String, key: String)], teamId: DbIdentifier? = nil, on req: Request) -> EventLoopFuture<[System]> {
        var futures: [EventLoopFuture<System>] = []
        for valueDouble in valueDoubles {
            futures.append(
                set(
                    value: valueDouble.value,
                    for: valueDouble.key,
                    teamId: teamId,
                    on: req
                )
            )
        }
        return futures.flatten(on: req)
    }
    
}
