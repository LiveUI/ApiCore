//
//  ApiCoreBase+Email.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 18/04/2019.
//

import Foundation
import MailCore
import Vapor


extension ApiCoreBase {
    
    static func setupEmails(_ services: inout Services) throws {
        let mail: Mailer.Config
        if !configuration.mail.mailgun.key.isEmpty, !configuration.mail.mailgun.domain.isEmpty {
            mail = Mailer.Config.mailgun(key: configuration.mail.mailgun.key, domain: configuration.mail.mailgun.domain)
            print("Configuring Mailgun for domain \(configuration.mail.mailgun.domain) as the main mailing service")
        } else if !configuration.mail.smtp.isEmpty {
            let parts = configuration.mail.smtp.split(separator: ";")
            guard parts.count >= 3 else {
                fatalError("Invalid SMTP configuration; Should be `smtp_server;username;password;port`, where port is an optional value which defaults to 25")
            }
            let port: Int32 = (parts.count >= 4) ? Int32(parts[3]) ?? 25 : 25
            mail = Mailer.Config.smtp(
                SMTP(
                    hostname: String(parts[0]),
                    email: String(parts[1]),
                    password: String(parts[2]),
                    port: port
                )
            )
            print("Configuring SMTP for \(parts[1])@\(parts[0]):\(port) as the main mailing service")
        } else {
            let message = "Email service hasn't been configured"
            if try Environment.detect() == .production {
                fatalError(message)
            } else {
                print(message)
                mail = Mailer.Config.none
            }
        }
        try Mailer(config: mail, registerOn: &services)
    }
    
}
