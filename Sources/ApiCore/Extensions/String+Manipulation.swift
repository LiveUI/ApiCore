//
//  String+Manipulation.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 18/01/2018.
//

import Foundation


extension String {
    
    public var safeText: String {
        var text = components(separatedBy: CharacterSet.alphanumerics.inverted).joined(separator: "-").lowercased()
        text = text.components(separatedBy: CharacterSet(charactersIn: "-")).filter { !$0.isEmpty }.joined(separator: "-")
        return text
    }
    
    public var maskedName: String {
        var text = components(separatedBy: CharacterSet.alphanumerics.inverted).joined(separator: "-").lowercased()
        text = text.components(separatedBy: CharacterSet(charactersIn: "-")).filter { !$0.isEmpty }.joined(separator: "-")
        return text
    }
    
    public var imageUrlFromMail: String {
        let text = try? Gravatar.link(fromEmail: self)
        return text ?? "https://www.gravatar.com/avatar/unknown"
    }
    
    public var initials: String {
        if count == 0 {
            return "??"
        } else if count <= 2 {
            return uppercased()
        }
        let capitals = filter { ("A"..."Z").contains($0) }
        if capitals.count < 2 {
            return uppercased().initials
        }
        return String(String(capitals).prefix(2)).uppercased()
    }
    
}
