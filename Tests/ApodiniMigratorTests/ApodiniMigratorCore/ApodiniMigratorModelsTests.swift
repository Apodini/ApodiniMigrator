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

final class ApodiniMigratorModelsTests: ApodiniMigratorXCTestCase {
    func testDSLEndpointIdentifier() {
        var errors: [ErrorCode] = []
        errors.addError(404, message: "Not found")
        let noIDEndpoint = Endpoint(
            handlerName: "SomeHandler",
            deltaIdentifier: "0.1.0.0.1",
            operation: .create,
            absolutePath: "/v1/test",
            parameters: [],
            response: .scalar(.bool),
            errors: errors
        )
        
        let withIDEndpoint = Endpoint(
            handlerName: "SomeHandler",
            deltaIdentifier: "getSomeHandler",
            operation: .read,
            absolutePath: "/v1/test",
            parameters: [],
            response: .scalar(.bool),
            errors: errors
        )
        
        XCTAssert(noIDEndpoint.deltaIdentifier == .init(noIDEndpoint.handlerName.lowerFirst))
        XCTAssert(withIDEndpoint.deltaIdentifier == "getSomeHandler")
    }
    
    func testWrappedContentParameters() throws {
        let param1 = Parameter(name: "first", typeInformation: .scalar(.string), parameterType: .content, isRequired: true)
        let param2 = Parameter(name: "second", typeInformation: .scalar(.int), parameterType: .content, isRequired: false)
        
        let endpoint = Endpoint(
            handlerName: "someHandler",
            deltaIdentifier: "id",
            operation: .create,
            absolutePath: "/v1/test",
            parameters: [param1, param2],
            response: .scalar(.bool),
            errors: []
        )
        
        XCTAssert(endpoint.parameters.count == 1)
        let contentParameter = try XCTUnwrap(endpoint.parameters.first)
        XCTAssert(contentParameter.isWrapped)
        XCTAssert(contentParameter.typeInformation.isObject)
        XCTAssert(contentParameter.necessity == .required)
        XCTAssert(contentParameter.name == "\(Parameter.wrappedContentParameter)")
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
        var document = Document()
        document.add(
            endpoint: .init(
                handlerName: "someHandler",
                deltaIdentifier: "endpoint",
                operation: .create,
                absolutePath: "/test1/test",
                parameters: [],
                response: .scalar(.bool),
                errors: []
            )
        )
        document.setServerPath("http://127.0.0.1:8080")
        document.setVersion(Version(prefix: "test", major: 1, minor: 2, patch: 3))
        
        document.setCoderConfigurations(.default, .default)
        XCTAssert(document.fileName == "api_test1.2.3")
        XCTAssert(!document.endpoints.isEmpty)
        XCTAssertEqual(document.metaData.versionedServerPath, "http://127.0.0.1:8080/test1")
        XCTAssert(!document.json.isEmpty)
        XCTAssert(!document.yaml.isEmpty)
    }
}
