//
//  ExampleACDTests.swift.swift
//
//  Created by ApodiniMigrator on 30.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import XCTest
@testable import ExampleACD

final class ExampleACDTests: XCTestCase {
    // MARK: - Encoder - Decoder
    private static let encoder = NetworkingService.encoder
    private static let decoder = NetworkingService.decoder
    
    func testContactMediator() throws {
        let jsonString = "{\"birthday\" : 644094905.83737397, \"name\" : \"\"}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(ContactMediator.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testDirection() throws {
        let jsonString = "\"left\""
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(Direction.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testStatus() throws {
        let jsonString = "\"ok\""
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(Status.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
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
