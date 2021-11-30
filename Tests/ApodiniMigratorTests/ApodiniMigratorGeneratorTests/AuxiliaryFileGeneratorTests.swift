//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import RESTMigrator
@testable import MigratorAPI
@testable import ApodiniMigratorCompare
import PathKit

final class AuxiliaryFileGeneratorTests: ApodiniMigratorXCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        FileHeaderComment.testsDate = .testsDate
    }
    
    func testTestFile() throws {
        let object: TypeInformation = .object(
            name: .init(name: "TestObject"),
            properties: [
                .init(name: "prop1", type: .scalar(.bool)),
                .init(name: "prop2", type: .scalar(.uint)),
                .init(name: "prop3", type: .dictionary(key: .int, value: .scalar(.string))),
                .init(name: "prop4", type: .scalar(.uint)),
                .init(name: "prop5", type: .optional(wrappedValue: .scalar(.string))),
                .init(name: "prop6", type: .scalar(.string))
            ]
        )
        
        let enumeration: TypeInformation = .enum(
            name: .init(name: "TestEnumeration"),
            rawValueType: .scalar(.string),
            cases: [
                .init("first"),
                .init("second")
            ]
        )

        let testFile = TestFileTemplate(name: "TestFile", models: [object, enumeration])
        
        XCTMigratorAssertEqual(testFile, .modelsTestFile)
    }
    
    func testAPIFile() throws {
        let endpoint = Endpoint(
            handlerName: "TestHandler",
            deltaIdentifier: "sayHelloWorld",
            operation: .read,
            absolutePath: "/v1/hello",
            parameters: [],
            response: .scalar(.string),
            errors: [.init(code: 404, message: "Could not say hello")]
        )

        // TODO find a shorter way to do this LOL
        @SharedNodeStorage
        var migratedEndpoints: [MigratedEndpoint]
        @SharedNodeReference
        var reference: [MigratedEndpoint]
        _reference = $migratedEndpoints
        reference = [MigratedEndpoint(endpoint: endpoint, unavailable: false, parameters: [], path: endpoint.path)]

        let file = APIFile($migratedEndpoints)
        
        XCTMigratorAssertEqual(file, .aPIFile)
    }
}
