//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorClientSupport
@testable import RESTMigrator

final class ApodiniMigratorModelsTests: ApodiniMigratorXCTestCase {
    func testDSLEndpointIdentifier() {
        var errors: [ErrorCode] = []
        errors.addError(404, message: "Not found")
        let noIDEndpoint = Endpoint(
            handlerName: "SomeHandler",
            deltaIdentifier: "0.1.0.0.1",
            operation: .create,
            communicationalPattern: .requestResponse,
            absolutePath: "/v1/test",
            parameters: [],
            response: .scalar(.bool),
            errors: errors
        )
        
        let withIDEndpoint = Endpoint(
            handlerName: "SomeHandler",
            deltaIdentifier: "getSomeHandler",
            operation: .read,
            communicationalPattern: .requestResponse,
            absolutePath: "/v1/test",
            parameters: [],
            response: .scalar(.bool),
            errors: errors
        )
        
        XCTAssert(noIDEndpoint.deltaIdentifier == .init(noIDEndpoint.handlerName.buildName()))
        XCTAssert(withIDEndpoint.deltaIdentifier == "getSomeHandler")
    }
    
    func testEndpointPath() throws {
        let pathString = "v1/user".json
        XCTAssertThrows(try EndpointPath.decode(from: pathString))
        
        let somePath = "/api/{id}/test".json
        XCTAssertThrows(try Endpoint.decode(from: somePath))
        
        let string = "/v1/{some}/users/{id}"
        let string1 = "/v1/{param}/users/{param}"
        let string2 = "/v2/{param}/users/{param}" // still considered equal, change is delegated to networking due to version change

        XCTAssertNotEqual(EndpointPath(string), EndpointPath(string1))
        XCTAssertEqual(EndpointPath(string1), EndpointPath(string2))
    }
    
    func testVersion() throws {
        let version = Version()
        XCTAssertEqual(version, .default)
        
        let versionFromString = try Version.decode(from: version.string.json)
        XCTAssertEqual(version, versionFromString)
        
        XCTAssertThrows(try Version.decode(from: "v123".json))
    }

    func testDocument() throws {
        let serviceInformation = ServiceInformation(
            version: Version(prefix: "test", major: 1, minor: 2, patch: 3),
            http: HTTPInformation(hostname: "127.0.0.1", port: 8080),
            exporters: RESTExporterConfiguration(encoderConfiguration: .default, decoderConfiguration: .default)
        )

        var document = APIDocument(serviceInformation: serviceInformation)
        document.add(
            endpoint: .init(
                handlerName: "someHandler",
                deltaIdentifier: "endpoint",
                operation: .create,
                communicationalPattern: .requestResponse,
                absolutePath: "/test1/test",
                parameters: [],
                response: .scalar(.bool),
                errors: []
            )
        )

        XCTAssertEqual(document.fileName, "api_test1.2.3")
        XCTAssertEqual(document.endpoints.isEmpty, false)
        XCTAssertEqual(document.serviceInformation.http.urlFormatted, "http://127.0.0.1:8080")
        XCTAssertEqual(document.json.isEmpty, false)
        XCTAssertEqual(document.yaml.isEmpty, false)
    }
}
