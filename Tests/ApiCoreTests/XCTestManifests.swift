import XCTest

extension ApiCoreTests {
    static let __allTests = [
        ("testLinuxTests", testLinuxTests),
        ("testRequestHoldsSessionID", testRequestHoldsSessionID),
    ]
}

extension AuthControllerTests {
    static let __allTests = [
        ("testHtmlInputRecoveryRequest", testHtmlInputRecoveryRequest),
        ("testInvalidGetAuthRequest", testInvalidGetAuthRequest),
        ("testInvalidGetTokenAuthRequest", testInvalidGetTokenAuthRequest),
        ("testInvalidPostAuthRequest", testInvalidPostAuthRequest),
        ("testInvalidPostTokenAuthRequest", testInvalidPostTokenAuthRequest),
        ("testLinuxTests", testLinuxTests),
        ("testStartRecovery", testStartRecovery),
        ("testValidGetAuthRequest", testValidGetAuthRequest),
        ("testValidGetTokenAuthRequest", testValidGetTokenAuthRequest),
        ("testValidPostAuthRequest", testValidPostAuthRequest),
        ("testValidPostTokenAuthRequest", testValidPostTokenAuthRequest),
    ]
}

extension GenericControllerTests {
    static let __allTests = [
        ("testLinuxTests", testLinuxTests),
        ("testPing", testPing),
        ("testTables", testTables),
        ("testTeapot", testTeapot),
        ("testUnknownDelete", testUnknownDelete),
        ("testUnknownGet", testUnknownGet),
        ("testUnknownPatch", testUnknownPatch),
        ("testUnknownPost", testUnknownPost),
        ("testUnknownPut", testUnknownPut),
    ]
}

extension StringCryptoTests {
    static let __allTests = [
        ("testPasswordHash", testPasswordHash),
    ]
}

extension TeamsControllerTests {
    static let __allTests = [
        ("testCreateTeam", testCreateTeam),
        ("testDeleteAdminTeam", testDeleteAdminTeam),
        ("testDeleteSingleTeam", testDeleteSingleTeam),
        ("testGetSingleTeam", testGetSingleTeam),
        ("testGetTeams", testGetTeams),
        ("testGetTeamUsers", testGetTeamUsers),
        ("testInvalidTeamNameCheck", testInvalidTeamNameCheck),
        ("testLinkUser", testLinkUser),
        ("testLinkUserThatDoesntExist", testLinkUserThatDoesntExist),
        ("testLinuxTests", testLinuxTests),
        ("testTryLinkUserWhereHeIs", testTryLinkUserWhereHeIs),
        ("testTryUnlinkUserWhereHeIsNot", testTryUnlinkUserWhereHeIsNot),
        ("testUnableToDeleteOtherPeoplesTeam", testUnableToDeleteOtherPeoplesTeam),
        ("testUnlinkUser", testUnlinkUser),
        ("testUnlinkUserThatDoesntExist", testUnlinkUserThatDoesntExist),
        ("testUnlinkYourselfWhenLastUser", testUnlinkYourselfWhenLastUser),
        ("testUpdateSingleTeam", testUpdateSingleTeam),
        ("testValidTeamNameCheck", testValidTeamNameCheck),
    ]
}

extension UsersControllerTests {
    static let __allTests = [
        ("testGetUsers", testGetUsers),
        ("testLinuxTests", testLinuxTests),
        ("testRegisterUser", testRegisterUser),
        ("testSearchUsersWithoutParams", testSearchUsersWithoutParams),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ApiCoreTests.__allTests),
        testCase(AuthControllerTests.__allTests),
        testCase(GenericControllerTests.__allTests),
        testCase(StringCryptoTests.__allTests),
        testCase(TeamsControllerTests.__allTests),
        testCase(UsersControllerTests.__allTests),
    ]
}
#endif
