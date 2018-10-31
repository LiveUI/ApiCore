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
import ErrorsCore
import JWT


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
        ("testStartRecovery", testStartRecovery),
        ("testSuccessfulPasswordCheck", testSuccessfulPasswordCheck),
        ("testFailingPasswordCheck", testFailingPasswordCheck),
        ("testHtmlInputRecoveryRequest", testHtmlInputRecoveryRequest),
        ("testExpiredGetTokenAuthRequest", testExpiredGetTokenAuthRequest),
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
            "Authorization": "Basic Y29yZUBsaXZldWkuaW86c3VwM3JTM2NyM3Q="
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
            // Should fail
        }
    }
    
    func testValidPostAuthRequest() {
        let req = try! HTTPRequest.testable.post(uri: "/auth", data: User.Auth.Login(email: "core@liveui.io", password: "sup3rS3cr3t").asJson(), headers: ["Content-Type": "application/json; charset=utf-8"])
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
            // Should fail
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
    
    func testExpiredGetTokenAuthRequest() {
        let t = token()
        
        let fakeReq = app.testable.fakeRequest()
        try! Token.query(on: fakeReq).all().wait().forEach({ token in
            token.expires = Date().addMonth(n: -2)
            _ = try! token.save(on: fakeReq).wait()
        })
        
        let req = HTTPRequest.testable.get(uri: "/token", headers: [
            "Authorization": "Token \(t.token)"
            ])
        do {
            let r = try app.testable.response(throwingTo: req)
            
            r.response.testable.debug()
            
            let data = r.response.testable.content(as: ErrorResponse.self)
            XCTAssertEqual(data!.error, "auth_error.authentication_failed")
            XCTAssertEqual(data!.description, "Authentication token has expired")
            
            XCTAssertTrue(r.response.testable.has(statusCode: .unauthorized), "Wrong status code")
            XCTAssertTrue(r.response.testable.has(contentType: "application/json; charset=utf-8"), "Missing content type")
            
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
            // Should fail
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
    
    func testSuccessfulPasswordCheck() {
        let data = try! User.Auth.Password(value: "p4sswoRd!")
        let req = try! HTTPRequest.testable.post(uri: "/auth/password-check", data: data.asJson(), headers: ["Content-Type": "application/json; charset=utf-8"])
        do {
            let r = try app.testable.response(throwingTo: req)
            
            r.response.testable.debug()
            
            XCTAssertTrue(r.response.testable.has(statusCode: .ok), "Wrong status code")
            XCTAssertTrue(r.response.testable.has(contentType: "application/json; charset=utf-8"), "Missing content type")
            XCTAssertTrue(r.response.testable.has(contentLength: 70), "Wrong content length") // Checks the content is correct(ish)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testFailingPasswordCheck() {
        let data = "{ \"password\": \"p4ss\" }".data(using: .utf8)!
        let req = HTTPRequest.testable.post(uri: "/auth/password-check", data: data, headers: ["Content-Type": "application/json; charset=utf-8"])
        do {
            let r = try app.testable.response(throwingTo: req)
            
            r.response.testable.debug()
            
            XCTAssertTrue(r.response.testable.has(statusCode: .notAcceptable), "Wrong status code")
            XCTAssertTrue(r.response.testable.has(contentType: "application/json; charset=utf-8"), "Missing content type")
            XCTAssertTrue(r.response.testable.has(contentLength: 98), "Wrong content length") // Checks the content is correct(ish)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    // MARK: Recovery tests
    
    func testStartRecovery() {
        startRecovery(type: .redirectUrl)
        startRecovery(type: .htmlInput)
    }

    func testHtmlInputRecoveryRequest() {
        let token = startRecovery(type: .htmlInput)
        finishRecovery(token: token)
    }
    
}


extension AuthControllerTests {
    
    private func finishRecovery(token: String) {
        let req = HTTPRequest.testable.post(uri: "/auth/finish-recovery?token=" + token, headers: ["Content-Type": "application/json"])
        
        do {
            let r = try app.testable.response(throwingTo: req)
            
            r.response.testable.debug()
            
            let fakeReq = app.testable.fakeRequest()
            let jwtService: JWTService = try fakeReq.make()
            guard let _ = try? JWT<JWTConfirmEmailPayload>(from: token, verifiedUsing: jwtService.signer).payload else {
                XCTFail("Missing payload")
                return
            }
            // TODO: Finish test!!!!!!!!!!!
        } catch {
            print(error)
            XCTFail(error.localizedDescription)
        }
    }
    
    enum RecoveryType {
        case htmlInput
        case redirectUrl
    }
    
    @discardableResult private func startRecovery(type: RecoveryType) -> String {
        let fakeReq = app.testable.fakeRequest()
        
        let target: String = (type == .redirectUrl) ? "https://example.com/target_url_which_would_call_finish_recovery_endpoint" : (fakeReq.serverURL().absoluteString.finished(with: "/") + "auth/input-recovery")
        let data = User.Auth.EmailConfirmation(email: "dev@liveui.io", targetUri: ((type == .redirectUrl) ? target : nil))
        let req = try! HTTPRequest.testable.post(uri: "/auth/start-recovery", data: data.asJson(), headers: ["Content-Type": "application/json; charset=utf-8"])
        var token: String = ""
        do {
            let r = try app.testable.response(throwingTo: req)
            
            r.response.testable.debug()
            
            XCTAssertTrue(r.response.testable.has(statusCode: .created), "Wrong status code")
            let data = r.response.testable.content(as: SuccessResponse.self)!
            XCTAssertEqual(data.code, "auth.recovery_sent")
            XCTAssertEqual(data.description, "Password recovery email has been sent")
            
            let mailer = try! r.request.make(MailerService.self) as! MailerMock
            XCTAssertTrue(ApiCoreBase.configuration.mail.email.count > 0, "Sender should not be empty")
            XCTAssertEqual(mailer.receivedMessage!.from, ApiCoreBase.configuration.mail.email, "Email has a wrong sender")
            XCTAssertEqual(mailer.receivedMessage!.to, "dev@liveui.io", "Email has a wrong recipient")
            XCTAssertEqual(mailer.receivedMessage!.subject, "Password recovery", "Email has a wrong subject")
            token = String(mailer.receivedMessage!.text.split(separator: "|")[1])
            XCTAssertEqual(mailer.receivedMessage!.text, """
                Hi Ondrej Rafaj
                
                Please confirm your email dev@liveui.io by clicking on this link \(target)?token=\(token)
                
                Recovery code is: |\(token)|
                
                Boost team
                """, "Email has a wrong text")
            XCTAssertEqual(mailer.receivedMessage!.html, """
                <h1>Hi Ondrej Rafaj</h1>
                <p>&nbsp;</p>
                <p>Please confirm your email dev@liveui.io by clicking on this <a href="\(target)?token=\(token)">link</a></p>
                <p>&nbsp;</p>
                <p>Recovery code is: <strong>\(token)</strong></p>
                <p>&nbsp;</p>
                <p>Boost team</p>
                """, "Email has a wrong html")
            
            XCTAssertTrue(r.response.testable.has(contentType: "application/json; charset=utf-8"), "Missing content type")
        } catch {
            print(error)
            XCTFail()
        }
        return token
    }
    
    private func token() -> Token.PublicFull {
        let req = try! HTTPRequest.testable.post(uri: "/auth", data: User.Auth.Login(email: "core@liveui.io", password: "sup3rS3cr3t").asJson(), headers: ["Content-Type": "application/json; charset=utf-8"])
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

