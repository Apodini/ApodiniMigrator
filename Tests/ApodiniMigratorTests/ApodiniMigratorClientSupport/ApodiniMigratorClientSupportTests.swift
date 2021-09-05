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

final class ApodiniMigratorClientSupportTests: ApodiniMigratorXCTestCase {
    private static let testEncoder = JSONEncoder()
    private static let testDecoder = JSONDecoder()
    
    struct CodableStruct: ApodiniMigratorCodable {
        static var encoder = ApodiniMigratorClientSupportTests.testEncoder
        static var decoder = ApodiniMigratorClientSupportTests.testDecoder
        
        let prop1: Int
        let prop2: String
    }
    
    func testApodiniMigratorCodable() {
        let encoder = Self.testEncoder
        let decoder = Self.testDecoder
        
        XCTAssert([CodableStruct].encoder === encoder)
        XCTAssert([CodableStruct].encoder.dataEncodingStrategy == encoder.dataEncodingStrategy)

        XCTAssert([CodableStruct].decoder.dateDecodingStrategy == decoder.dateDecodingStrategy)
        XCTAssert([CodableStruct].decoder.dataDecodingStrategy == decoder.dataDecodingStrategy)

        encoder.configured(with: .init(dateEncodingStrategy: .millisecondsSince1970, dataEncodingStrategy: .base64))

        XCTAssert([Int: CodableStruct].encoder.dateEncodingStrategy == encoder.dateEncodingStrategy)
        XCTAssert([Int: CodableStruct].encoder.dataEncodingStrategy == encoder.dataEncodingStrategy)

        XCTAssert([String: CodableStruct].decoder === decoder)
        XCTAssert([String: CodableStruct].decoder.dataDecodingStrategy == decoder.dataDecodingStrategy)

        decoder.configured(with: .init(dateDecodingStrategy: .iso8601, dataDecodingStrategy: .deferredToData))

        XCTAssert(CodableStruct?.encoder.dateEncodingStrategy == encoder.dateEncodingStrategy)
        XCTAssert(CodableStruct?.encoder === encoder)

        XCTAssert(CodableStruct?.decoder.dateDecodingStrategy == decoder.dateDecodingStrategy)
        XCTAssert(CodableStruct?.decoder.dataDecodingStrategy == decoder.dataDecodingStrategy)
    }
    
    func testJSONValue() throws {
        let json: JSONValue =
        """
        {
            "prop1" : 1234,
            "prop2" : "Hello world"
        }
        """
        
        let instance = XCTAssertNoThrowWithResult(try CodableStruct.instance(from: json))
        XCTAssert(instance.prop1 == 1234)
        XCTAssert(instance.prop2 == "Hello world")
    }
}
