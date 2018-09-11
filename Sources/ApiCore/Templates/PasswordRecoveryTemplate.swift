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
        <style>
            * {
                font-family: Helvetica, Arial, sans-serif;
                text-align: center;
            }
            form, body, h2 {
                margin-top: 44px;
            }
            body {
                width: 300px;
                margin-left: auto;
                margin-right: auto;
            }
            img {
                width: 98px;
                border-radius: 5px;
            }
            h1 {
                font-size: large;
            }
            form {

            }
            h2 {
                font-size: medium;
                margin-bottom: 44px;
            }
            p.input {
                text-align: right;
            }
            label {
                text-align: right;
                clear: both;
                float:left;
                margin-right:15px;
            }
            button {
                margin-top: 44px;
                color: white;
                font-weight: bold;
                background-color: #92b5ee;
                border: none;
                border-radius: 4px;
                font-size: medium;
                padding-top: 8px;
                padding-bottom: 8px;
                padding-left: 12px;
                padding-right: 12px;
            }

        </style>
    </head>
    <body>
        <p><img src="#(system.info.url)/server/image/256" alt="#(system.info.name)" /></p>
        <h1>Hi #(user.firstname) #(user.lastname)</h1>

        <!--
            #finish (below) contains an API link to which you need to send the form data either as JSON data or as a standard webform.
            You can also append a target URL to redirect the user to when done by appending '&target=http://example.com/all_is_dandy'.
            Target is an optional value and if not set a JSON (API) result will be returned.
        -->
        <form action="#(finish)">
            <h2>Please set your new #(system.info.name) password here:</h2>
            <p class="input">
                <label>Password:</label> <input name="password" type="password" value="" />
            </p>
            <p class="input">
                <label>Password again:</label> <input name="verification" type="password" value="" />
            </p>
            <p><button type="submit">Reset password</button></p>
        </form>
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
