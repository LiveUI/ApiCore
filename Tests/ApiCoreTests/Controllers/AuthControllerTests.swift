//
//  AuthControllerTests.swift
//  ApiCoreTests
//
//  Created by Ondrej Rafaj on 28/02/2018.
//

import XCTest
import Vapor
import VaporTestTools
import FluentTestTools
import ApiCoreTestTools
@testable import ApiCore
import MailCore
import MailCoreTestTools

class AuthControllerTests: XCTestCase, UsersTestCase, LinuxTests {
    
    var app: Application!
    
    var adminTeam: Team!
    
    var user1: User!
    var user2: User!
    
    // MARK: Linux
    
    static let allTests: [(String, Any)] = [
        ("testValidGetAuthRequest", testValidGetAuthRequest),
        ("testInvalidGetAuthRequest", testInvalidGetAuthRequest),
        ("testValidPostAuthRequest", testValidPostAuthRequest),
        ("testInvalidPostAuthRequest", testInvalidPostAuthRequest),
        ("testValidGetTokenAuthRequest", testValidGetTokenAuthRequest),
        ("testInvalidGetTokenAuthRequest", testInvalidGetTokenAuthRequest),
        ("testValidPostTokenAuthRequest", testValidPostTokenAuthRequest),
        ("testInvalidPostTokenAuthRequest", testInvalidPostTokenAuthRequest),
        ("testValidStartRecoveryRequest", testValidStartRecoveryRequest),
        ("testLinuxTests", testLinuxTests)
    ]
    
    func testLinuxTests() {
        doTestLinuxTestsAreOk()
    }
    
    // MARK: Setup
    
    override func setUp() {
        super.setUp()
        
        app = Application.testable.newApiCoreTestApp()
        
        app.testable.delete(allFor: Token.self)
        
        setupUsers()
    }
    
    // MARK: Login tests
    
    func testValidGetAuthRequest() {
        let req = HTTPRequest.testable.get(uri: "/auth", headers: [
            "Authorization": "Basic YWRtaW5AbGl2ZXVpLmlvOmFkbWlu"
            ])
        do {
            let r = try app.testable.response(throwingTo: req)
            
            checkAuthResult(r.response)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testInvalidGetAuthRequest() {
        let req = HTTPRequest.testable.get(uri: "/auth", headers: ["Bad-Headers": "For-Sure"])
        do {
            _ = try app.testable.response(throwingTo: req)
            XCTFail()
        } catch {
            // Should fails
        }
    }
    
    func testValidPostAuthRequest() {
        let req = try! HTTPRequest.testable.post(uri: "/auth", data: User.Auth.Login(email: "admin@liveui.io", password: "admin").asJson(), headers: ["Content-Type": "application/json; charset=utf-8"])
        do {
            let r = try app.testable.response(throwingTo: req)
            
            checkAuthResult(r.response)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testInvalidPostAuthRequest() {
        let req = HTTPRequest.testable.post(uri: "/auth", data: Data())
        do {
            _ = try app.testable.response(throwingTo: req)
            XCTFail()
        } catch {
            // Should fails
        }
    }
    
    // MARK: Token auth tests
    
    func testValidGetTokenAuthRequest() {
        let t = token()
        
        let req = HTTPRequest.testable.get(uri: "/token", headers: [
            "Authorization": "Token \(t.token)"
            ])
        do {
            let r = try app.testable.response(throwingTo: req)
            
            checkTokenResult(r.response)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testInvalidGetTokenAuthRequest() {
        let req = HTTPRequest.testable.get(uri: "/token", headers: ["Bad-Headers": "For-Sure"])
        do {
            _ = try app.testable.response(throwingTo: req)
            XCTFail()
        } catch {
            // Should fails
        }
    }
    
    func testValidPostTokenAuthRequest() {
        let t = token()
        
        let req = try! HTTPRequest.testable.post(uri: "/token", data: User.Auth.Token(token: t.token).asJson(), headers: ["Content-Type": "application/json; charset=utf-8"])
        do {
            let r = try app.testable.response(throwingTo: req)
            
            checkTokenResult(r.response)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testInvalidPostTokenAuthRequest() {
        let req = HTTPRequest.testable.post(uri: "/token", data: Data())
        do {
            _ = try app.testable.response(throwingTo: req)
            XCTFail()
        } catch {
            // Should fail
        }
    }

    // MARK: Recovery tests

    func testValidStartRecoveryRequest() {
        let data = User.Auth.StartRecovery(email: "dev@liveui.io", targetUri: "https://example.com/target")
        let req = try! HTTPRequest.testable.post(uri: "/auth/start-recovery", data: data.asJson(), headers: ["Content-Type": "application/json; charset=utf-8"])
        do {
            let r = try app.testable.response(throwingTo: req)
            XCTAssertEqual(r.response.http.status, HTTPStatus.ok)

            let mailer = try! r.request.make(MailerService.self) as! MailerMock
            XCTAssertEqual(mailer.receivedMessage!.from, "ondrej.rafaj@gmail.com", "Email has a wrong sender")
            XCTAssertEqual(mailer.receivedMessage!.to, "dev@liveui.io", "Email has a wrong recipient")
            XCTAssertEqual(mailer.receivedMessage!.subject, "Password recovery", "Email has a wrong subject")
            XCTAssertEqual(mailer.receivedMessage!.text, """
Hi Ondrej Rafaj
Please confirm your email lemmy@liveui.io by clicking on this link http://www.example.com/#what-the-heck
HTML - huhuhu woe :)
Boost team
""", "Email has a wrong text")
            XCTAssertEqual(mailer.receivedMessage!.html, """
<h1>Hi Ondrej Rafaj</h1>
<p>Please confirm your email lemmy@liveui.io by clicking on this <a href="http://www.example.com/#what-the-heck">link</a></p>
<p>HTML - huhuhu woe :)</p>
<p>Boost team</p>
""", "Email has a wrong html")

            XCTAssertTrue(r.response.testable.has(statusCode: .created), "Wrong status code")
            XCTAssertTrue(r.response.testable.has(contentType: "application/json; charset=utf-8"), "Missing content type")
        } catch {
            print(error)
            XCTFail()
        }
    }

}


extension AuthControllerTests {
    
    private func token() -> Token.PublicFull {
        let req = try! HTTPRequest.testable.post(uri: "/auth", data: User.Auth.Login(email: "admin@liveui.io", password: "admin").asJson(), headers: ["Content-Type": "application/json; charset=utf-8"])
        let r = try! app.testable.response(throwingTo: req)
        r.response.testable.debug()
        let token = r.response.testable.content(as: Token.PublicFull.self)!
        return token
    }
    
    private func checkAuthResult(_ res: Response) {
        res.testable.debug()
        
        let count = app.testable.count(allFor: Token.self)
        XCTAssertEqual(count, 1, "There should be one auth key entry in the db")
        
        let data = res.testable.content(as: Token.PublicFull.self)
        
        XCTAssertNotNil(data, "Token can't be nil")
        if let data = data {
            XCTAssertNotNil(data.id, "Token id can't be nil")
            XCTAssertFalse(data.token.isEmpty, "Token data should be present")
            XCTAssertTrue(data.expires.timeIntervalSince1970 > 0, "Token data should be present")
            XCTAssertFalse(data.user.id!.uuidString.isEmpty, "Token data should be present")
        }
        
        XCTAssertTrue(res.testable.has(statusCode: .ok), "Wrong status code")
        XCTAssertTrue(res.testable.has(contentType: "application/json; charset=utf-8"), "Missing correct content type")
    }
    
    private func checkTokenResult(_ res: Response) {
        res.testable.debug()
        
        let data = res.testable.content(as: Token.Public.self)
        
        XCTAssertNotNil(data, "Token can't be nil")
        if let data = data {
            XCTAssertNotNil(data.id, "Token id can't be nil")
            XCTAssertTrue(data.expires.timeIntervalSince1970 > Date().timeIntervalSince1970, "Token expiry date should be present")
            XCTAssertFalse(data.user.id!.uuidString.isEmpty, "User ID data should be present")
        }
        
        XCTAssertTrue(res.testable.has(statusCode: .ok), "Wrong status code")
        XCTAssertTrue(res.testable.has(contentType: "application/json; charset=utf-8"), "Missing correct content type")
    }
    
}

