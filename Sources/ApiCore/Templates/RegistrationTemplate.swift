//
//  RegistrationTemplate.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 23/03/2018.
//

import Foundation


/// BAsic registration template
public class RegistrationTemplate: EmailTemplate {
    
    /// Name of the template
    public static var name: String = "registration"
    
    /// Text data
    public static var string: String = """
        Hi #(user.firstname) #(user.lastname)
        
        To finish your registration, please confirm your email #(user.email) by clicking on this link #(link)
        
        Verification code is: |#(verification)|
        
        ApiCore
        """
    
    /// HTML data
    public static var html: String? = """
        <h1>Hi #(user.firstname) #(user.lastname)</h1>
        <p>&nbsp;</p>
        <p>To finish your registration, please confirm your email #(user.email) by clicking on this <a href="#(link)">link</a></p>
        <p>&nbsp;</p>
        <p>Verification code is: <strong>#(verification)</strong></p>
        <p>&nbsp;</p>
        <p>ApiCore</p>
        """
    
}
