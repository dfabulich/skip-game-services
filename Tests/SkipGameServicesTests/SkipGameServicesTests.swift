// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

import Testing
import OSLog
import Foundation
@testable import SkipGameServices

let logger: Logger = Logger(subsystem: "SkipGameServices", category: "Tests")

@Suite struct SkipGameServicesTests {

    @Test @MainActor func skipGameServices() throws {
        logger.log("running testSkipGameServices")
        #expect(1 + 2 == 3, "basic test")
        #expect(SkipGameServices.shared === SkipGameServices.shared)
    }

    @Test func decodeType() throws {
        // load the TestData.json file from the Resources folder and decode it into a struct
        let resourceURL: URL = try #require(Bundle.module.url(forResource: "TestData", withExtension: "json"))
        let testData = try JSONDecoder().decode(TestData.self, from: Data(contentsOf: resourceURL))
        #expect(testData.testModuleName == "SkipGameServices")
    }

}

struct TestData : Codable, Hashable {
    var testModuleName: String
}
