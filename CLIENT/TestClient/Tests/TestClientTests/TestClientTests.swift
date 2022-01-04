//
//  TestClientTests.swift
//
//  Created by ApodiniMigrator on 14.11.21
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import XCTest
@testable import TestClient
@testable import ApodiniMigratorClientSupport

final class TestClientTests: XCTestCase {
    func testGreeting() throws {
        let json: JSONValue =
        """
        {
            "greet" : ""
        }
        """
        
        let instance = XCTAssertNoThrowWithResult(try Greeting.instance(from: json))
        XCTAssertNoThrow(try Greeting.encoder.encode(instance))
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
