//
//  EmailTemplatePasswordRecovery.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 11/10/2018.
//

import Foundation
import Templator


public class EmailTemplatePasswordRecoveryHTML: TemplateSource {
    
    public static var name: String = "email.password-recovery.html"
    
    public static var link: String = ""
    
    public static var deletable: Bool = false
    
}


public class EmailTemplatePasswordRecoveryPlain: TemplateSource {
    
    public static var name: String = "email.password-recovery.plain"
    
    public static var link: String = ""
    
    public static var deletable: Bool = false
    
}
