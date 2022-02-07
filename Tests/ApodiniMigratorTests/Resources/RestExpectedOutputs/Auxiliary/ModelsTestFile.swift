//
//  Created by ApodiniMigrator on 15.08.20
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import XCTest
@testable import ApodiniMigrator
@testable import ApodiniMigratorClientSupport

final class ApodiniMigratorTests: XCTestCase {
    func testTestEnumeration() throws {
        let json: JSONValue =
        """
        "first"
        """
        
        let instance = XCTAssertNoThrowWithResult(try TestEnumeration.instance(from: json))
        XCTAssertNoThrow(try TestEnumeration.encoder.encode(instance))
    }
    
    func testTestObject() throws {
        let json: JSONValue =
        """
        {
        "prop1" : false,
        "prop2" : 0,
        "prop3" : {},
        "prop4" : 0,
        "prop5" : null,
        "prop6" : ""
        }
        """
        
        let instance = XCTAssertNoThrowWithResult(try TestObject.instance(from: json))
        XCTAssertNoThrow(try TestObject.encoder.encode(instance))
    }
    
    func XCTAssertNoThrowWithResult<T>(_ expression: @autoclosure () throws -> T) -> T {
        XCTAssertNoThrow(try expression())
        do {
            return try expression()
        } catch {
            preconditionFailure("Expression threw an error: \(error.localizedDescription)")
        }
    }
}
