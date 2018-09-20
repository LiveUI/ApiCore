//
//  String+Manipulation.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 18/01/2018.
//

import Foundation


extension String {
    
    /// Convert to safe text (convert-to-safe-text)
    public var safeText: String {
        var text = components(separatedBy: CharacterSet.alphanumerics.inverted).joined(separator: "-").lowercased()
        text = text.components(separatedBy: CharacterSet(charactersIn: "-")).filter { !$0.isEmpty }.joined(separator: "-")
        return text
    }
    
    /// Snake case from dotted syntax
    public func snake_cased() -> String {
        let text = split(separator: ".").joined(separator: "_")
        return text
    }
    
    /// Masked name
    public var maskedName: String {
        var text = components(separatedBy: CharacterSet.alphanumerics.inverted).joined(separator: "-").lowercased()
        text = text.components(separatedBy: CharacterSet(charactersIn: "-")).filter { !$0.isEmpty }.joined(separator: "-")
        return text
    }
    
    /// Gravatar MD5 hash from an email
    public var imageUrlHashFromMail: String {
        return md5 ?? ""
    }
    
    /// Name inititials (two letters) from a string
    public var initials: String {
        if count == 0 {
            return "??"
        } else if count <= 2 {
            return uppercased()
        }
        let capitals = filter { ("A"..."Z").contains($0) }
        if capitals.count < 2 {
            let capitalizedString = split(separator: " ").map { element -> String in
                element.capitalized
            }.joined(separator: " ")
            let capitals = capitalizedString.filter { ("A"..."Z").contains($0) }
            if capitals.count >= 2 {
                return String(String(capitals).prefix(2)).uppercased()
            }
            return uppercased().initials
        }
        return String(String(capitals).prefix(2)).uppercased()
    }
    
    /// Convert string to boolean if possible
    func asBool() -> Bool? {
        switch self.lowercased() {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    
}


extension Optional where Wrapped == String {
    
    /// Convert optional string to boolean
    func asBool() -> Bool {
        switch self?.lowercased() {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return false
        }
    }
    
}

