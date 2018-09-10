//
//  RegistrationTemplate.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 23/03/2018.
//

import Foundation


public class PasswordRecoveryTemplate: WebTemplate {
    
    public static var name: String = "password-recovery-web"
    
    public static var html: String = """
        <html>
            <head>
                <title>Password recovery</title>
            </head>
            <body>
            <h1>Hi #(user.firstname) #(user.lastname)</h1>
            <form>
                <p>Please set your new password here:</p>
                <p>
                    <label>Password:</label> <input name="password" type="password" value="" />
                </p>
                <p>
                    <label>Password again:</label> <input name="verification" type="password" value="" />
                </p>
                <p><button type="submit">Reset password</button></p>
            <form>
            </body>
        </html>
        """
    
}


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
        <p>Please confirm your email #(user.email) by clicking on this <a href="#(link)">link</a></p>
        <p>Recovery code is: <strong>#(verification)</strong></p>
        <p>Boost team</p>
        """
    
}
