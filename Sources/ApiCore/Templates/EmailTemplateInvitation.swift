//
//  EmailTemplateInvitation.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 11/10/2018.
//

import Foundation
import Templator


/// Basic invitation template
public class EmailTemplateInvitationHTML: TemplateSource {
    
    /// Name of the template
    public static var name: String = "email.invitation.html"
    
    public static var link: String = "https://raw.githubusercontent.com/LiveUI/ApiCore/master/Resources/Templates/email.invitation.html.leaf"
    
    public static var deletable: Bool = false
    
}


/// Basic invitation template
public class EmailTemplateInvitationPlain: TemplateSource {
    
    /// Name of the template
    public static var name: String = "email.invitation.plain"
    
    public static var link: String = "https://raw.githubusercontent.com/LiveUI/ApiCore/master/Resources/Templates/email.invitation.plain.leaf"
    
    public static var deletable: Bool = false
    
}
