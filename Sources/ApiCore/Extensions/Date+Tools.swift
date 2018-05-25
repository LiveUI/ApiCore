//
//  Date+Tools.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 14/01/2018.
//

import Foundation


extension Date {
    
    /// Add n number of months
    public func addMonth(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .month, value: n, to: self)!
    }
    
    /// Add n number of days
    public func addDay(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .day, value: n, to: self)!
    }
    
    /// Add n number of minutes
    public func addMinute(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .minute, value: n, to: self)!
    }
    
    /// Add n number of seconds
    public func addSec(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .second, value: n, to: self)!
    }
    
    /// Day in a month
    public var day: Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        return calendar?.component(NSCalendar.Unit.day, from: self) ?? 0
    }
    
    /// Month in a year
    public var month: Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        return calendar?.component(NSCalendar.Unit.month, from: self) ?? 0
    }
    
    /// Year
    public var year: Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        return calendar?.component(NSCalendar.Unit.year, from: self) ?? 0
    }
    
    /// Date folder path (YYYY/mm/dd)
    public var dateFolderPath: String {
        return "\(year)/\(month)/\(day)"
    }
    
}
