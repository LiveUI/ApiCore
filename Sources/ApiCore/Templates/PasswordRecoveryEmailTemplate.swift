//
//  PasswordRecoveryEmailTemplate.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 11/10/2018.
//

import Foundation


public class PasswordRecoveryEmailTemplate: EmailTemplate {
    
    public static var name: String = "password-recovery-email"
    
    public static var string: String = """
        Hi #(user.firstname) #(user.lastname)
        
        Please confirm your email #(user.email) by clicking on this link #(link)
        
        Recovery code is: |#(verification)|
        
        Boost team
        """
    
    public static var html: String? = """
        <h1>Hi #(user.firstname) #(user.lastname)</h1>
        <p>&nbsp;</p>
        <p>Please confirm your email #(user.email) by clicking on this <a href="#(link)">link</a></p>
        <p>&nbsp;</p>
        <p>Recovery code is: <strong>#(verification)</strong></p>
        <p>&nbsp;</p>
        <p>Boost team</p>
        """
    
}
