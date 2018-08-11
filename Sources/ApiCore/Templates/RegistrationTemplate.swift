//
//  RegistrationTemplate.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 23/03/2018.
//

import Foundation


/// BAsic registration template
public class RegistrationTemplate: Template {
    
    /// Name of the template
    public static  var name: String = "registration"
    
    /// Text data
    public static  var string: String = """
Hi #(user.firstname) #(user.lastname)
Please confirm your email #(user.email) by clicking on this link http://www.example.com/#what-the-heck
HTML - huhuhu woe :)
Boost team
"""
    
    /// HTML data
    public static  var html: String? = """
<h1>Hi #(user.firstname) #(user.lastname)</h1>
<p>Please confirm your email #(user.email) by clicking on this <a href="http://www.example.com/#what-the-heck">link</a></p>
<p>HTML - huhuhu woe :)</p>
<p>Boost team</p>
"""
    
}
