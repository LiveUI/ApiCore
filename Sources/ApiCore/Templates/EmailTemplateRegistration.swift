//
//  EmailTemplateRegistration.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 23/03/2018.
//

import Foundation
import Templator


/// Basic registration template
public class EmailTemplateRegistrationHTML: TemplateSource {
    
    /// Name of the template
    public static var name: String = "email.registration.html"
    
    public static var link: String = "https://raw.githubusercontent.com/LiveUI/ApiCore/master/Resources/Templates/email.registration.html.leaf"
    
    public static var deletable: Bool = false
    
}


/// Basic registration template
public class EmailTemplateRegistrationPlain: TemplateSource {
    
    /// Name of the template
    public static var name: String = "email.registration.plain"
    
    public static var link: String = "https://raw.githubusercontent.com/LiveUI/ApiCore/master/Resources/Templates/email.registration.plain.leaf"
    
    public static var deletable: Bool = false
    
}
