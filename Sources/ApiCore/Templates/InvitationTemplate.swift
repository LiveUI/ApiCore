//
//  InvitationTemplate.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 08/10/2018.
//

import Foundation


/// Basic invitation template
public class InvitationTemplate: EmailTemplate {
    
    /// Name of the template
    public static var name: String = "invitation"
    
    /// Text data
    public static var string: String = """
        Hi #(user.firstname) #(user.lastname)
        
        You have been invited to one of our teams by #(sender.firstname) #(sender.lastname) (#(sender.email)).
        You can confirm your registration now by clicking on this link #(link)
        
        Verification code is: |#(verification)|
        
        ApiCore
        """
    
    /// HTML data
    public static var html: String? = """
        <h1>Hi #(user.firstname) #(user.lastname)</h1>
        <p>&nbsp;</p>
        <p>
            You have been invited to one of our teams by #(sender.firstname) #(sender.lastname) (#(sender.email)).<br />
            You can confirm your registration now by clicking on this <a href="#(link)">link</a>
        </p>
        <p>&nbsp;</p>
        <p>Verification code is: <strong>#(verification)</strong></p>
        <p>&nbsp;</p>
        <p>ApiCore</p>
        """
    
}
