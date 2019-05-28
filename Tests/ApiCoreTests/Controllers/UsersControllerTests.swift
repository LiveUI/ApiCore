//
//  UsersControllerTests.swift
//  ApiCoreTests
//
//  Created by Ondrej Rafaj on 28/02/2018.
//

import Foundation
import XCTest
@testable import ApiCore
import Vapor
import VaporTestTools
import FluentTestTools
import ApiCoreTestTools
import MailCore
import MailCoreTestTools
import ErrorsCore


class UsersControllerTests: XCTestCase, UsersTestCase, LinuxTests {
    
    struct UserData: Codable {
        public var username: String?
        public var firstname: String?
        public var lastname: String?
        public var email: String?
        public var redirect: String?
        public var password: String?
        
        static var invitation: UserData {
            return UserData(
                username: nil,
                firstname: "Lemmy",
                lastname: "Kilmister",
                email: "lemmy@liveui.io",
                redirect: "url",
                password: nil
            )
        }
        
        static var registration: UserData {
            return UserData(
                username: "username",
                firstname: "Lemmy",
                lastname: "Kilmister",
                email: "lemmy@liveui.io",
                redirect: "url",
                password: "sup3rS3cr3t"
            )
        }
        
    }
    
    var app: Application!
    
    var adminTeam: Team!
    var user1: CoreUser!
    var user2: CoreUser!
    
    // MARK: Linux
    
    static let allTests: [(String, Any)] = [
        ("testLinuxTests", testLinuxTests),
        ("testGetUsers", testGetUsers),
        ("testRegisterUser", testRegisterUser),
        ("testInviteUser", testInviteUser),
        ("testInviteExistingUser", testInviteExistingUser),
        ("testIdentify", testIdentify),
        ("testSearchUsersWithoutParams", testSearchUsersWithoutParams),
        ("testRegistrationsHaveBeenDisabled", testRegistrationsHaveBeenDisabled),
        ("testRegisterUserValidDomain", testRegisterUserValidDomain),
        ("testRegisterUserInvalidDomain1", testRegisterUserInvalidDomain1),
        ("testRegisterUserInvalidDomain2", testRegisterUserInvalidDomain2)
    ]
    
    func testLinuxTests() {
        doTestLinuxTestsAreOk()
    }
    
    // MARK: Setup
    
    override func setUp() {
        super.setUp()
        
        app = Application.testable.newApiCoreTestApp()
        
        ApiCoreBase.configuration.mail.email = "admin@apicore"
        
        setupUsers()
    }
    
    // MARK: Tests
    
    func testGetUsers() {
        let req = HTTPRequest.testable.get(uri: "/users", authorizedUser: user1, on: app)
        let r = app.testable.response(to: req)
        
        r.response.testable.debug()
        
        XCTAssertTrue(r.response.testable.has(statusCode: .ok), "Wrong status code")
        XCTAssertTrue(r.response.testable.has(contentType: "application/json; charset=utf-8"), "Missing content type")
        
        let users = r.response.testable.content(as: [CoreUser.Display].self)!
        XCTAssertEqual(users.count, 2, "There should be two users in the database")
        XCTAssertTrue(users.contains(where: { (user) -> Bool in
            return user.id == user1.id && user.id != nil
        }), "Newly created user is not present in the database")
        XCTAssertTrue(users.contains(where: { (user) -> Bool in
            return user.id == user2.id && user.id != nil
        }), "Newly created user is not present in the database")
    }
    
    func testRegisterUser() {
        let post = UserData.registration
        
        let req = try! HTTPRequest.testable.post(uri: "/users", data: post.asJson(), headers: [
            "Content-Type": "application/json; charset=utf-8"
            ]
        )
        let r = app.testable.response(to: req)
        
        r.response.testable.debug()
        
        // Check returned data
        let object = r.response.testable.content(as: User.Display.self)!
        XCTAssertEqual(object.firstname, post.firstname, "Firstname doesn't match")
        XCTAssertEqual(object.lastname, post.lastname, "Lastname doesn't match")
        XCTAssertEqual(object.email, post.email, "Email doesn't match")
        
        // Check it has been actually saved
        let user = app.testable.one(for: User.self, id: object.id!)!
        XCTAssertEqual(user.firstname, post.firstname, "Firstname doesn't match")
        XCTAssertEqual(user.lastname, post.lastname, "Lastname doesn't match")
        XCTAssertEqual(user.email, post.email, "Email doesn't match")
        XCTAssertTrue(post.password!.verify(against: user.password!), "Password doesn't match")
        XCTAssertEqual(user.disabled, false, "Disabled should be false")
        XCTAssertEqual(user.su, false, "SU should be false")
        
        // Test email has been sent (on a mock email client ... obviously)
        let mailer = try! r.request.make(MailerService.self) as! MailerMock
        XCTAssertEqual(mailer.receivedMessage!.from, "admin@apicore", "Email has a wrong sender")
        XCTAssertEqual(mailer.receivedMessage!.to, "lemmy@liveui.io", "Email has a wrong recipient")
        XCTAssertEqual(mailer.receivedMessage!.subject, "Registration", "Email has a wrong subject")
        
        let token = String(mailer.receivedMessage!.text.split(separator: "|")[1])
        
        XCTAssertEqual(mailer.receivedMessage!.text, """
            Hi Lemmy Kilmister
            
            To finish your registration, please confirm your email lemmy@liveui.io by clicking on this link http://localhost:8080/users/verify?token=\(token)
            
            Verification code is: |\(token)|
            
            ApiCore
            """, "Email has a wrong text")
        XCTAssertEqual(mailer.receivedMessage!.html, """
            <h1>Hi Lemmy Kilmister</h1>
            <p>&nbsp;</p>
            <p>To finish your registration, please confirm your email lemmy@liveui.io by clicking on this <a href=\"http://localhost:8080/users/verify?token=\(token)\">link</a></p>
            <p>&nbsp;</p>
            <p>Verification code is: <strong>\(token)</strong></p>
            <p>&nbsp;</p>
            <p>ApiCore</p>
            """, "Email has a wrong html")
        
        XCTAssertTrue(r.response.testable.has(statusCode: .created), "Wrong status code")
        XCTAssertTrue(r.response.testable.has(contentType: "application/json; charset=utf-8"), "Missing content type")
    }
    
    func testInviteUser() {
        let post = UserData.invitation
        let req = try! HTTPRequest.testable.post(uri: "/users/invite", data: post.asJson(), headers: [
            "Content-Type": "application/json; charset=utf-8"
            ], authorizedUser: user1, on: app)
        let r = app.testable.response(to: req)
        
        r.response.testable.debug()
        
        // Check returned data
        let object = r.response.testable.content(as: User.Display.self)!
        XCTAssertEqual(object.firstname, post.firstname, "Firstname doesn't match")
        XCTAssertEqual(object.lastname, post.lastname, "Lastname doesn't match")
        XCTAssertEqual(object.email, post.email, "Email doesn't match")
        
        // Check it has been actually saved
        let user = app.testable.one(for: User.self, id: object.id!)!
        XCTAssertEqual(user.username, "", "Username has to be empty")
        XCTAssertEqual(user.firstname, post.firstname, "Firstname doesn't match")
        XCTAssertEqual(user.lastname, post.lastname, "Lastname doesn't match")
        XCTAssertEqual(user.email, post.email, "Email doesn't match")
        XCTAssertNil(user.password, "Password has to be nil")
        XCTAssertEqual(user.disabled, false, "Disabled should be false")
        XCTAssertEqual(user.su, false, "SU should be false")
        
        // Test email has been sent (on a mock email client ... obviously)
        let mailer = try! r.request.make(MailerService.self) as! MailerMock
        XCTAssertEqual(mailer.receivedMessage!.from, "admin@apicore", "Email has a wrong sender")
        XCTAssertEqual(mailer.receivedMessage!.to, "lemmy@liveui.io", "Email has a wrong recipient")
        XCTAssertEqual(mailer.receivedMessage!.subject, "Invitation", "Email has a wrong subject")
        
        let token = String(mailer.receivedMessage!.text.split(separator: "|")[1])
        
        XCTAssertEqual(mailer.receivedMessage!.text, """
            Hi Lemmy Kilmister
            
            You have been invited to one of our teams by Super Admin (core@liveui.io).
            You can confirm your registration now by clicking on this link http://localhost:8080/users/input-invite?token=\(token)
            
            Verification code is: |\(token)|
            
            ApiCore
            """, "Email has a wrong text")
        XCTAssertEqual(mailer.receivedMessage!.html, """
            <h1>Hi Lemmy Kilmister</h1>
            <p>&nbsp;</p>
            <p>
                You have been invited to one of our teams by Super Admin (core@liveui.io).<br />
                You can confirm your registration now by clicking on this <a href=\"http://localhost:8080/users/input-invite?token=\(token)\">link</a>
            </p>
            <p>&nbsp;</p>
            <p>Verification code is: <strong>\(token)</strong></p>
            <p>&nbsp;</p>
            <p>ApiCore</p>
            
            """, "Email has a wrong html")
        
        XCTAssertTrue(r.response.testable.has(statusCode: .created), "Wrong status code")
        XCTAssertTrue(r.response.testable.has(contentType: "application/json; charset=utf-8"), "Missing content type")
    }
    
    func testInviteExistingUser() {
        var post = UserData.invitation
        post.firstname = "Super"
        post.lastname = "Admin"
        post.email = "core@liveui.io"
        
        let req = try! HTTPRequest.testable.post(uri: "/users/invite", data: post.asJson(), headers: [
            "Content-Type": "application/json; charset=utf-8"
            ], authorizedUser: user2, on: app)
        let r = app.testable.response(to: req)
        
        r.response.testable.debug()
        
        // Check returned data
        let object = r.response.testable.content(as: ErrorResponse.self)!
        XCTAssertEqual(object.error, "auth.email_exists", "Error code doesn't match")
        XCTAssertEqual(object.description, "Email already exists", "Error description doesn't match")
        
        XCTAssertTrue(r.response.testable.has(statusCode: .preconditionFailed), "Wrong status code")
        XCTAssertTrue(r.response.testable.has(contentType: "application/json; charset=utf-8"), "Missing content type")
    }
    
    func testIdentify() {
        let req = HTTPRequest.testable.get(uri: "/users/identify?search=\(user2.email)", authorizedUser: user1, on: app)
        let r = app.testable.response(to: req)
        
        r.response.testable.debug()
        
        // Check returned data
        let object = r.response.testable.content(as: User.Identify.self)!
        XCTAssertEqual(object.id, user2.id, "User ID doesn't match")
        XCTAssertEqual(object.username, user2.username, "User nickname doesn't match")
        
        XCTAssertTrue(r.response.testable.has(statusCode: .ok), "Wrong status code")
        XCTAssertTrue(r.response.testable.has(contentType: "application/json; charset=utf-8"), "Missing content type")
    }
    
    func testSearchUsersWithoutParams() {
        let req = HTTPRequest.testable.get(uri: "/users/global", authorizedUser: user1, on: app)
        let r = app.testable.response(to: req)
        
        r.response.testable.debug()
        
        XCTAssertTrue(r.response.testable.has(statusCode: .ok), "Wrong status code")
        XCTAssertTrue(r.response.testable.has(contentType: "application/json; charset=utf-8"), "Missing content type")
        
        let users = r.response.testable.content(as: [CoreUser.AllSearch].self)!
        XCTAssertEqual(users.count, 2, "There should be two users in the database")
        XCTAssertEqual(users[0].id, user1.id, "Avatar is not in the correct format")
        XCTAssertEqual(users[0].avatar, "4702ca7b9c3932d3ce546e246abeb0a3", "Avatar hash (MD5 of an email) is not in the correct format")
    }
    
    func testRegistrationsHaveBeenDisabled() {
        ApiCoreBase.configuration.auth.allowRegistrations = false
        
        let post = User.Registration(username: "lemmy", firstname: "Lemmy", lastname: "Kilmister", email: "lemmy@liveui.io", password: "passw0rd")
        let req = try! HTTPRequest.testable.post(uri: "/users", data: post.asJson(), headers: [
            "Content-Type": "application/json; charset=utf-8"
            ]
        )
        
        do {
            // QUESTION: Why do I need to do this instead of getting a response??????
            let _ = try app.testable.response(throwingTo: req)
            XCTFail("This should fail!")
        } catch {
            let error = error as! FrontendError
            XCTAssertEqual(error.identifier, "users_error.not_permitted")
            XCTAssertEqual(error.reason, "Registrations have been disabled")
        }
    }
    
    func testRegisterUserValidDomain() {
        ApiCoreBase.configuration.auth.allowedDomainsForRegistration = ["liveui.io"]
        
        let post = UserData.registration
        let req = try! HTTPRequest.testable.post(uri: "/users", data: post.asJson(), headers: [
            "Content-Type": "application/json; charset=utf-8"
            ]
        )
        let r = app.testable.response(to: req)
        
        r.response.testable.debug()
        
        XCTAssertTrue(r.response.testable.has(statusCode: .created), "Wrong status code")
        XCTAssertTrue(r.response.testable.has(contentType: "application/json; charset=utf-8"), "Missing content type")
    }
    
    func testRegisterUserInvalidDomain1() {
        ApiCoreBase.configuration.auth.allowedDomainsForRegistration = ["example.com"]
        
        let post = UserData.registration
        let req = try! HTTPRequest.testable.post(uri: "/users", data: post.asJson(), headers: [
            "Content-Type": "application/json; charset=utf-8"
            ]
        )
        let r = app.testable.response(to: req)
        
        r.response.testable.debug()
        
        let message = r.response.testable.content(as: ErrorResponse.self)!
        XCTAssertEqual(message.error, "users_error.not_permitted")
        XCTAssertEqual(message.description, "Registrations have been only enabled for certain domain names")
        
        XCTAssertTrue(r.response.testable.has(statusCode: .methodNotAllowed), "Wrong status code")
        XCTAssertTrue(r.response.testable.has(contentType: "application/json; charset=utf-8"), "Missing content type")
    }
    
    func testRegisterUserInvalidDomain2() {
        ApiCoreBase.configuration.auth.allowedDomainsForRegistration = ["example.com"]
        
        let post = UserData.registration
        let req = try! HTTPRequest.testable.post(uri: "/users", data: post.asJson(), headers: [
            "Content-Type": "application/json; charset=utf-8"
            ]
        )
        let r = app.testable.response(to: req)
        
        r.response.testable.debug()
        
        let message = r.response.testable.content(as: ErrorResponse.self)!
        XCTAssertEqual(message.error, "users_error.not_permitted")
        XCTAssertEqual(message.description, "Registrations have been only enabled for certain domain names")
        
        XCTAssertTrue(r.response.testable.has(statusCode: .methodNotAllowed), "Wrong status code")
        XCTAssertTrue(r.response.testable.has(contentType: "application/json; charset=utf-8"), "Missing content type")
    }
    
}
